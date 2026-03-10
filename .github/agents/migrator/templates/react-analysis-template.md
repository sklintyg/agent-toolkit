# React 16 to React 18+ Migration - General Analysis Instructions

**Document Version:** 1.0  
**Purpose:** Template for creating general analysis instructions for React 16 to React 18+ migrations  
**Target:** Generate comprehensive migration analysis framework

---

## Overview

This template provides the foundation for creating application-specific analysis instructions for
migrating from React 16 to React 18+. It should be customized based on common React migration
patterns and the specific application's architecture.

---

## 1. Initial Application Assessment

### 1.1 Current React Setup Analysis

**Analyze:**
- Current React version (16.x)
- Current React DOM version
- Package manager (npm, yarn, pnpm)
- Build tool (Webpack, Create React App, Vite, Parcel)
- Node.js version compatibility
- TypeScript or JavaScript (check if TypeScript is used)

**Document:**
- List all React-related dependencies
- Identify React 16 specific patterns
- Note any deprecated APIs in use
- Identify build tool version and configuration

### 1.2 Component Architecture Analysis

**Identify:**
- Total number of components
- Class components vs. functional components ratio
- Components using lifecycle methods (componentDidMount, componentDidUpdate, etc.)
- Components using UNSAFE_ lifecycle methods
- Components using legacy context API
- Components using deprecated patterns (findDOMNode, string refs)

**Categorize Components:**
- **Class Components:** List components that need conversion to functional components
- **Lifecycle Methods:** Document which lifecycle methods are used and their purposes
- **HOCs and Render Props:** Identify candidates for custom hooks conversion
- **Error Boundaries:** Locate existing error boundaries (will remain as class components)

### 1.3 State Management Analysis

**Current State Management:**
- Identify state management solution (Redux, MobX, Context API, local state)
- Analyze Redux version if used (Redux Toolkit recommended)
- Document Context API usage (legacy vs. modern)
- Identify prop drilling patterns

**Hooks Usage:**
- List all hooks currently in use
- Identify custom hooks
- Note any incorrect hook usage patterns
- Document dependencies that might need hooks updates

---

## 2. Dependencies and Package Analysis

### 2.1 Core Dependencies Audit

**React Ecosystem:**
- React and ReactDOM version audit
- React Router version (migrate to v6+ if needed)
- State management libraries compatibility
- Form libraries (migrate to React Hook Form if beneficial)
- Data fetching libraries (consider React Query/SWR)

**Styling Dependencies:**
- CSS-in-JS libraries (Styled Components, Emotion) - ensure React 18 compatibility
- CSS Modules configuration
- Tailwind CSS version if used
- Sass/Less preprocessor versions

**Testing Dependencies:**
- Testing library versions (Enzyme → React Testing Library)
- Jest version and configuration
- E2E testing framework (Cypress, Playwright)
- Test utilities compatibility with React 18

**Build and Dev Tools:**
- Build tool version and React 18 compatibility
- ESLint plugins for React 18 (eslint-plugin-react-hooks)
- Prettier configuration
- TypeScript version if used

### 2.2 Third-Party Component Libraries

**Identify:**
- UI component libraries (Material-UI, Ant Design, etc.)
- Date pickers, modals, tooltips, dropdowns
- Rich text editors
- Chart and visualization libraries
- Animation libraries

**Verify:**
- React 18 compatibility for each library
- Required version updates
- Breaking changes in library updates
- Alternatives if library is abandoned

### 2.3 Dependency Migration Plan

**Categorize:**
- **Compatible:** Dependencies that work with React 18 as-is
- **Needs Update:** Dependencies requiring version updates
- **Incompatible:** Dependencies that need replacement
- **Deprecated:** Dependencies that should be removed

**Priority:**
- Critical dependencies first (React, ReactDOM, React Router)
- Testing libraries early (to enable testing during migration)
- UI libraries (may require significant refactoring)
- Utility libraries last

---

## 3. Component Migration Analysis

### 3.1 Class Component Conversion Strategy

**For Each Class Component:**

1. **Analyze Component Complexity:**
    - Simple components (few lifecycle methods) - easy conversion
    - Complex components (multiple lifecycle methods, refs) - careful planning needed
    - Error boundaries - remain as class components

2. **Map Lifecycle Methods to Hooks:**
    - `componentDidMount` → `useEffect` with empty dependency array
    - `componentDidUpdate` → `useEffect` with specific dependencies
    - `componentWillUnmount` → `useEffect` cleanup function
    - `shouldComponentUpdate` → `React.memo()` or `useMemo`
    - `getDerivedStateFromProps` → `useState` with conditional updates
    - `getSnapshotBeforeUpdate` → `useLayoutEffect` (rare)

3. **Identify State Conversion:**
    - `this.state` → `useState` or `useReducer`
    - Complex state objects → consider splitting into multiple `useState` calls or use `useReducer`
    - State updates → ensure functional updates if depending on previous state

4. **Handle Refs:**
    - `this.refs.xxx` (string refs) → `useRef`
    - `React.createRef()` → `useRef`
    - Callback refs → `useCallback` with ref

5. **Context API Migration:**
    - Legacy context (`getChildContext`, `contextTypes`) → Context API with hooks
    - `static contextType` → `useContext` hook

### 3.2 Hooks Conversion Patterns

**Common Patterns:**

- **State:** `this.state` → `useState` or `useReducer`
- **Effects:** Lifecycle methods → `useEffect`
- **Context:** `this.context` → `useContext`
- **Refs:** `this.refs` or `createRef` → `useRef`
- **Memoization:** `shouldComponentUpdate` → `React.memo` or `useMemo`
- **Callbacks:** Instance methods → `useCallback` (if passed as props)

**Custom Hooks Extraction:**
- Identify reusable logic across components
- Extract data fetching logic into custom hooks
- Create hooks for form handling, local storage, etc.

### 3.3 Deprecated Pattern Removal

**Identify and Replace:**

1. **UNSAFE_ Lifecycle Methods:**
    - `UNSAFE_componentWillMount` → `useEffect` or remove
    - `UNSAFE_componentWillReceiveProps` → `useEffect` with proper dependencies
    - `UNSAFE_componentWillUpdate` → `useEffect` or remove

2. **findDOMNode():**
    - Replace with `useRef` and ref forwarding
    - Access DOM nodes directly through refs

3. **String Refs:**
    - `ref="myRef"` → `useRef` with `ref={myRef}`

4. **Legacy Context API:**
    - `getChildContext`, `childContextTypes` → `React.createContext()` with Provider
    - `contextTypes` → `useContext` hook

---

## 4. React 18 New Features Adoption

### 4.1 New Root API

**Migration Required:**
- Replace `ReactDOM.render()` with `createRoot().render()`
- Replace `ReactDOM.hydrate()` with `hydrateRoot()`
- Update entry point (index.js or main.jsx)

**Before:**
```javascript
ReactDOM.render(<App />, document.getElementById('root'));
```

**After:**
```javascript
import { createRoot } from 'react-dom/client';
const root = createRoot(document.getElementById('root'));
root.render(<App />);
```

### 4.2 Automatic Batching

**Benefits:**
- Automatic in React 18 (even in promises, timeouts, native event handlers)
- Improves performance automatically
- No code changes required in most cases

**Check for:**
- Code relying on synchronous updates
- Code using `unstable_batchedUpdates` (can be removed)

### 4.3 Concurrent Features (Optional)

**Evaluate Adoption:**

1. **Transitions:**
    - Use `startTransition` for non-urgent updates (e.g., filtering, searching)
    - Keeps UI responsive during expensive updates
    - `useTransition` hook for loading states

2. **Suspense for Data Fetching:**
    - Enhanced Suspense in React 18
    - Works with React Query, Relay, or custom implementations
    - Show loading states declaratively

3. **useDeferredValue:**
    - Defer expensive re-renders
    - Useful for search inputs, filtering large lists

4. **useId:**
    - Generate unique IDs for accessibility
    - Useful for form labels, ARIA attributes

### 4.4 Strict Mode Changes

**React 18 Strict Mode:**
- Double-invokes effects in development
- Helps identify issues with effect cleanup
- Ensure proper cleanup in `useEffect`

**Test and Verify:**
- All components work correctly in Strict Mode
- No missing cleanup functions
- No side effects in render phase

---

## 5. Testing Migration Analysis

### 5.1 Test Framework Assessment

**Current Testing Setup:**
- Identify test runner (Jest, Vitest)
- Component testing library (Enzyme, React Testing Library)
- E2E testing framework (Cypress, Playwright)
- Test coverage percentage

**Migration Requirements:**
- Migrate from Enzyme to React Testing Library (recommended)
- Update Jest configuration for React 18
- Update test utilities (renderHook, act, etc.)

### 6.2 Enzyme to React Testing Library Migration

**For Each Test File:**

1. **Replace Enzyme Imports:**
    - `shallow`, `mount`, `render` → `render` from React Testing Library
    - `wrapper.find()` → `screen.getByRole()`, `screen.getByText()`, etc.

2. **Update Query Patterns:**
    - Avoid testing implementation details
    - Query by role, label, or text (user-centric)
    - Use `userEvent` instead of `fireEvent` for interactions

3. **Update Assertions:**
    - Focus on what users see and do
    - Test behavior, not internal state
    - Use accessible queries

**Common Enzyme → RTL Mappings:**
- `wrapper.find('.class')` → `screen.getByRole('button')`
- `wrapper.state()` → Test behavior instead
- `wrapper.prop()` → Test rendered output
- `wrapper.simulate('click')` → `userEvent.click()`

### 6.3 React 18 Test Updates

**Update Test Utilities:**

1. **createRoot in Tests:**
    - Update test setup to use `createRoot`
    - React Testing Library handles this automatically

2. **act() Warnings:**
    - React 18 has stricter `act()` requirements
    - Ensure all state updates are wrapped properly
    - React Testing Library handles most cases automatically

3. **Async Testing:**
    - Use `waitFor`, `findBy` queries for async operations
    - Properly handle loading states

### 6.4 Test Configuration Updates

**Update:**
- Jest configuration for React 18
- Test environment (jsdom version)
- ESLint test rules
- MSW (Mock Service Worker) for API mocking

---

## 7. Routing and Navigation Analysis

### 7.1 React Router Migration

**If Using React Router v5 or Earlier:**

**Identify:**
- Router version
- All route definitions
- Navigation patterns (Link, useHistory, withRouter)

**Migration to v6:**
- Replace `<Switch>` with `<Routes>`
- Update route syntax: `<Route path="/" component={Home} />` → `<Route path="/" element={<Home />} />`
- Replace `useHistory` with `useNavigate`
- Replace `useRouteMatch` with `useMatch`
- Remove `exact` prop (default behavior in v6)

### 7.2 Code Splitting Updates

**Identify:**
- Route-based code splitting with `React.lazy()`
- Suspense boundaries

**Ensure:**
- Suspense is properly configured
- Error boundaries wrap Suspense
- Loading states are user-friendly

---

## 8. Build Configuration Analysis

### 7.1 Build Tool Migration

**Current Build Tool:**
- Identify tool (Webpack, CRA, Vite, Parcel)
- Version and configuration

**React 18 Compatibility:**
- Verify build tool supports React 18
- Update if necessary
- Consider migrating to Vite for better performance

### 7.2 Configuration Updates

**Webpack Configuration:**
- Update Webpack to v5+ if needed
- Update React-related plugins and loaders
- Ensure Fast Refresh is configured

**Create React App:**
- Update to CRA 5+ for React 18 support
- Consider ejecting if heavy customization needed
- Or migrate to Vite

**Vite Configuration:**
- Update Vite to latest version
- Ensure React plugin is configured
- Update environment variable prefixes (VITE_ instead of REACT_APP_)

### 7.3 ESLint and Prettier

**Update:**
- ESLint React plugins for React 18
- `eslint-plugin-react-hooks` rules
- Update Prettier if needed
- TypeScript ESLint if using TypeScript

---

## 8. Performance and Optimization Analysis

### 8.1 Current Performance Assessment

**Measure:**
- Bundle size
- Initial load time
- Time to interactive
- Largest Contentful Paint (LCP)
- First Input Delay (FID)
- Cumulative Layout Shift (CLS)

**Tools:**
- React DevTools Profiler
- Lighthouse
- Web Vitals library

### 8.2 Optimization Opportunities

**Code Splitting:**
- Implement route-based code splitting
- Split large components with `React.lazy()`
- Use Suspense boundaries

**Memoization:**
- Identify expensive components for `React.memo()`
- Use `useMemo` for expensive computations
- Use `useCallback` for stable function references

**Bundle Optimization:**
- Analyze bundle with webpack-bundle-analyzer
- Remove unused dependencies
- Ensure tree shaking is working

### 8.3 React 18 Performance Features

**Leverage:**
- Automatic batching (automatic)
- Transitions for non-urgent updates
- useDeferredValue for expensive re-renders
- Suspense for better loading experiences

---

## 9. Migration Strategy and Planning

### 9.1 Incremental Migration Approach

**Phase 1: Preparation**
- Analyze test coverage and add critical missing tests
- Update dependencies (React, ReactDOM, React Router)
- Update build tools and configuration
- Update testing libraries
- Update ESLint and code quality tools

**Phase 2: Core Migration**
- Migrate entry point to createRoot()
- Convert class components to functional components (start with simple ones)
- Migrate from Enzyme to React Testing Library
- Update routing to React Router v6 if needed

**Phase 3: Optimization**
- Remove deprecated patterns
- Implement code splitting
- Add error boundaries
- Optimize performance

**Phase 4: Cleanup**
- Remove unused dependencies
- Remove dead code
- Update documentation
- Final testing and QA
- Verify test coverage maintained or improved

### 9.2 Risk Assessment

**High Risk Areas:**
- Complex class components with multiple lifecycle methods
- Components using deprecated APIs
- Third-party libraries not compatible with React 18
- Custom build configurations
- Areas with low or no test coverage

**Mitigation:**
- Add tests before migrating high-risk areas
- Thorough testing at each step
- Gradual migration (component by component)
- Maintain backward compatibility during migration
- Create feature flags if needed

### 9.3 Testing Strategy

**Testing Levels:**
- Unit tests for hooks and utilities
- Component tests for UI behavior
- Integration tests for feature flows
- E2E tests for critical user journeys

**Test Early and Often:**
- Verify baseline coverage before migration
- Test after each component migration
- Maintain or improve test coverage percentage
- Add tests for new React 18 features
- Monitor for regressions continuously

---

## 10. Documentation and Communication

### 10.1 Document Migration Progress

**Track:**
- Components migrated
- Tests updated
- Dependencies updated
- Issues encountered and resolved

### 10.2 Team Communication

**Communicate:**
- Migration plan and timeline
- Breaking changes
- New patterns and conventions
- Training needs

### 10.3 Update Documentation

**Update:**
- README with React 18 information
- Component documentation
- Development setup instructions
- Deployment guides if changed

---

## 11. Post-Migration Validation

### 11.1 Functional Testing

**Verify:**
- All features work correctly
- No console errors or warnings
- All user flows function as expected
- Forms submit correctly
- Navigation works properly

### 11.2 Performance Testing

**Measure:**
- Bundle size hasn't increased significantly
- Performance metrics maintained or improved
- No performance regressions
- React DevTools Profiler shows no issues

### 11.3 Test Coverage Validation

**Verify:**
- Test coverage maintained or improved from baseline
- All tests pass with React 18
- No flaky or skipped tests
- Coverage meets target goals (80%+ overall)
- Critical paths have adequate coverage

**Compare:**
- Pre-migration coverage vs. post-migration coverage
- Identify any coverage gaps introduced during migration
- Add tests for any gaps found

### 11.4 Accessibility Testing

**Verify:**
- Keyboard navigation works
- Screen readers work correctly
- ARIA labels are proper
- Color contrast meets standards

### 11.5 Cross-Browser Testing

**Test on:**
- Chrome
- Firefox
- Safari
- Edge
- Mobile browsers

---

## 12. Rollback Plan

### 12.1 Version Control Strategy

**Ensure:**
- All changes in feature branch
- Frequent commits with clear messages
- Easy rollback to previous state if needed

### 12.2 Deployment Strategy

**Implement:**
- Gradual rollout if possible
- Feature flags for new features
- Quick rollback procedure
- Monitoring and alerting

---

## Notes for Application-Specific Guide

When creating the application-specific migration guide, use this template as a foundation and:

1. **Customize** based on the actual application structure
2. **Prioritize** migration steps based on complexity and risk
3. **Detail** specific components, files, and patterns found in the repository
4. **Include** code examples from the actual codebase
5. **Reference** the requirements document for specific technology choices
6. **Plan** incremental steps that leave the application functional after each increment
7. **Flag** any uncertainties or decisions needed with `OBSERVE`

The application-specific guide should be thorough and complete - it's the roadmap for the entire
migration implementation phase.

