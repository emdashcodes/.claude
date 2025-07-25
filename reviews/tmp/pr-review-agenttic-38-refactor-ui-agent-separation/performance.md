# Performance Review: Refactor the UI so it doesn't have any agent initialisation responsibility

## Summary

This refactoring significantly improves performance by separating UI concerns from state management and agent logic. The removal of Redux from the UI package and the move to a prop-driven architecture reduces bundle size, minimizes re-renders, and creates better opportunities for code splitting. However, there are several areas where performance could be further optimized, particularly around markdown parsing, message transformation, and component memoization.

## Strengths

- **Significant bundle size reduction** by removing Redux and associated dependencies from UI package
- **Better code splitting opportunities** with clear separation between UI and client packages
- **Reduced re-render scope** - UI components only re-render when their props change
- **Elimination of Redux overhead** - no more action dispatching, middleware processing, or selector computations
- **Improved tree-shaking** - UI components can be imported individually without bringing in state management

## Concerns

### Critical Issues

- **Markdown parsing performance** (`packages/agenttic-client/src/react/useAgentChat.ts:63-66`, commit: `refactor-ui`): Creating a new React component for every text part on every render is inefficient
  ```diff
  - const ParsedMarkdown = () => parseMarkdownToComponent( part.text, {
  -     components: markdownComponents,
  -     extensions: markdownExtensions,
  - } );
  + const ParsedMarkdown = React.memo(() => parseMarkdownToComponent( part.text, {
  +     components: markdownComponents,
  +     extensions: markdownExtensions,
  + }));
  ```

- **Message transformation runs on every state update** (`packages/agenttic-client/src/react/useAgentChat.ts:309-322`, commit: `refactor-ui`): The `transformClientMessageToUI` function is called for all messages whenever markdown components/extensions change
  ```javascript
  // Re-transform existing client messages with new components
  const updatedUIMessages = prev.clientMessages
      .map( ( msg ) => transformClientMessageToUI( msg, updatedComponents, prev.markdownExtensions ) )
      .filter( ( msg ): msg is UIMessage => msg !== null );
  ```

- **Duplicate dependency on chart library** (`packages/agenttic-ui/package.json:92` and `packages/agenttic-client/package.json:50`, commit: `refactor-ui`): Both packages depend on `@automattic/charts` and `@visx/xychart`, increasing bundle size

### Suggestions

- **Missing React.memo on AgentUI** (`packages/agenttic-ui/src/components/AgentUI.tsx:41`, commit: `refactor-ui`): The main UI component should be memoized to prevent unnecessary re-renders
  ```diff
  - export const AgentUI: React.FC< AgentChatUIProps > = ( {
  + export const AgentUI: React.FC< AgentChatUIProps > = React.memo( ( {
  ```

- **Inefficient message filtering** (`packages/agenttic-client/src/react/useAgentChat.ts:315-318`, commit: `refactor-ui`): Creates new Set on every render
  ```diff
  - const clientMessageIds = new Set( updatedClientHistory.map( msg => msg.messageId ) );
  + const clientMessageIds = useMemo(
  +     () => new Set( updatedClientHistory.map( msg => msg.messageId ) ),
  +     [updatedClientHistory]
  + );
  ```

## Specific Feedback

### File: packages/agenttic-client/src/react/useAgentChat.ts

- **Lines 209-218** (`commit: refactor-ui`): State initialization creates unnecessary object allocations
  ```diff
  - const [ state, setState ] = useState< AgentChatState >( {
  -     clientMessages: [],
  -     uiMessages: [],
  -     isThinking: false,
  -     isSendingMessage: false,
  -     error: isValidConfig ? null : 'Invalid agent configuration',
  -     suggestions: [],
  -     markdownComponents: {},
  -     markdownExtensions: {},
  - } );
  + const [ state, setState ] = useState< AgentChatState >( () => ({
  +     clientMessages: [],
  +     uiMessages: [],
  +     isThinking: false,
  +     isSendingMessage: false,
  +     error: isValidConfig ? null : 'Invalid agent configuration',
  +     suggestions: [],
  +     markdownComponents: {},
  +     markdownExtensions: {},
  + }));
  ```

- **Lines 273-346** (`commit: refactor-ui`): The `onSubmit` callback recreates on every render due to dependencies
  ```diff
  const onSubmit = useCallback(
      async ( message: string ) => {
          // ... implementation
      },
  -   [ agentConfig.agentId, agentConfig.sessionId, isValidConfig ]
  +   [ agentConfig.agentId, agentConfig.sessionId, isValidConfig, state.markdownComponents, state.markdownExtensions ]
  );
  ```

### File: packages/agenttic-ui/src/components/chat/Chat.tsx

- **Line 45** (`commit: refactor-ui`): Chat component receives many props but lacks memoization
  ```javascript
  export function Chat( {
      messages,
      isThinking,
      isSendingMessage,
      error,
      onSubmit,
      // ... many more props
  }: ChatProps ) {
  ```

- **Lines 90-92** (`commit: refactor-ui`): Motion values are recreated on every render
  ```diff
  - const x = useMotionValue( 0 );
  - const y = useMotionValue( 0 );
  - const dragControls = useDragControls();
  + const x = useMemo(() => useMotionValue( 0 ), []);
  + const y = useMemo(() => useMotionValue( 0 ), []);
  + const dragControls = useMemo(() => useDragControls(), []);
  ```

### File: demo/src/App.tsx

- **Lines 119-126** (`commit: refactor-ui`): The demo properly memoizes suggestionSets but could benefit from useReducer for complex state
  ```javascript
  const suggestionSets = useMemo(
      () => ( {
          button: [...],
          heading: [...],
          // ... more sets
      } ),
      []
  );
  ```

- **Line 16** (`commit: refactor-ui`): Chart styles imported from source instead of dist
  ```diff
  - import '../../packages/agenttic-client/src/markdown-extensions/charts/charts.css';
  + import '@automattic/agenttic-client/markdown-extensions/charts/charts.css';
  ```

## Recommendations

1. **Implement message transformation caching**: Add a memoization layer for `transformClientMessageToUI` to avoid re-parsing messages that haven't changed

2. **Lazy load chart components**: Since charts are now in the client package, implement dynamic imports for chart components to reduce initial bundle size

3. **Add React.memo to all exported UI components**: Prevent unnecessary re-renders by memoizing Chat, Messages, Message, and other components

4. **Optimize markdown parsing**: Consider using a lightweight markdown parser or implementing a custom parser for common patterns, with lazy loading for complex features

5. **Implement virtual scrolling**: For long conversations, add virtualization to the Messages component to improve rendering performance

6. **Bundle size analysis**: Run a bundle analyzer to identify any remaining duplicated dependencies between packages

7. **Consider moving to Preact for UI package**: Since the UI is now purely presentational, Preact could significantly reduce bundle size while maintaining compatibility

8. **Add performance monitoring**: Implement React DevTools Profiler API to track render performance in production