# [YOUR-APP] - React 16 to React 18+ Migration Requirements

**Document Version:** 1.0  
**Date:** [DATE]  
**Application:** [YOUR-APP]  
**Migration Target:** React 18+ with modern React patterns

---

## Executive Summary

This document defines the requirements and design choices for migrating [YOUR-APP] from React 16 to
React 18+. The migration will follow modern React best practices while maintaining focus
on performance, maintainability, and leveraging new React features like Concurrent Rendering and Automatic Batching.

---

## 1. Core Technology Stack

### 1.1 Framework and Runtime

- **React Version:** 18.3.1 (or latest stable 18.x)
- **React DOM Version:** 18.3.1 (must match React version)
- **Node Version:** Node 18+ (LTS) or Node 20+ (recommended)
- **Package Manager:** npm, yarn, or pnpm (specify based on project)
- **Build Tool:** Vite (recommended) or Create React App / Webpack (if already in use)
- **TypeScript:** TypeScript 5+ (strongly recommended for new projects)

### 1.2 State Management

- **Primary:** React Context API + Hooks (useState, useReducer, useContext)
- **Alternative:** Redux Toolkit (if complex state management needed)
- **Server State:** React Query (TanStack Query) or SWR for data fetching
- **Form State:** React Hook Form for form management
- **Migration Notes:**
    - Replace class components with functional components + hooks
    - Migrate from componentDidMount/componentDidUpdate to useEffect
    - Replace HOCs and render props with custom hooks where appropriate

### 1.3 Testing Strategy

- **Unit Tests:** Jest with React Testing Library
- **Component Tests:** React Testing Library (prefer over Enzyme)
- **E2E Tests:** Playwright or Cypress
- **Coverage:** Maintain or improve existing test coverage
- **Migration Notes:**
    - Migrate from Enzyme to React Testing Library
    - Update test utilities for React 18 (act() changes, createRoot)
    - Test concurrent features if used
- **Test Structure:**
    - Unit tests for utility functions and custom hooks
    - Component tests for UI behavior
    - Integration tests for user flows
    - Use MSW (Mock Service Worker) for API mocking
    - Prefer user-centric testing (query by role, label, text)

### 1.4 Styling Solution

- **Options:** (Choose based on existing project)
    - CSS Modules (good for existing projects)
    - Styled Components or Emotion (CSS-in-JS)
    - Tailwind CSS (utility-first)
    - Plain CSS/SCSS (if already in use)
- **Migration Notes:**
    - Ensure styling solution is React 18 compatible
    - Update any CSS-in-JS libraries to latest versions
    - Consider migrating to modern styling solutions if beneficial

### 1.5 Build Configuration

- **Modern Build Tools:**
    - Vite (recommended for fast development and modern features)
    - Webpack 5+ (if already in use, ensure React 18 compatibility)
    - Create React App 5+ (supports React 18)
- **Bundle Optimization:**
    - Code splitting with React.lazy() and Suspense
    - Tree shaking for unused code elimination
    - Modern JavaScript output (ES2020+)
- **Environment Variables:** Use .env files with appropriate prefixes (REACT_APP_ or VITE_)

### 1.6 Code Quality and Standards

- **Linting:** ESLint with React 18 rules (eslint-plugin-react-hooks)
- **Formatting:** Prettier for consistent code formatting
- **Type Safety:** TypeScript or PropTypes (TypeScript strongly recommended)
- **Code Style:** Follow React best practices and functional programming patterns
- **Hooks Rules:** Enforce React Hooks rules via ESLint

### 1.7 Naming Conventions

Follow React and JavaScript best practices for naming:

- **Components:** PascalCase (e.g., `UserProfile`, `ProductList`, `NavigationBar`)
- **Hooks:** camelCase with `use` prefix (e.g., `useAuth`, `useLocalStorage`, `useFetchData`)
- **Utilities:** camelCase (e.g., `formatDate`, `calculateTotal`, `validateEmail`)
- **Constants:** UPPER_SNAKE_CASE (e.g., `API_BASE_URL`, `MAX_RETRY_ATTEMPTS`)
- **Files:** Match component names (e.g., `UserProfile.jsx`, `ProductList.tsx`)
- **Avoid:** Generic names like `Component1`, `utils`, `helpers` without context

**Examples:**

- ✅ `UserProfile.jsx`, `useAuth.js`, `ProductList.tsx`, `API_BASE_URL`
- ✅ Custom hooks: `useFetchUsers`, `useDebounce`, `useLocalStorage`
- ❌ `Component1.jsx`, `thing.js`, `temp.jsx`, `myComponent`

---

## 2. Architecture and Design Principles

### 2.1 Component Architecture

- **Strategy:** Functional components with hooks exclusively (no class components)
- **Component Types:**
    - **Container Components:** Handle state and logic, connect to APIs
    - **Presentational Components:** Pure UI components, receive data via props
    - **Layout Components:** Handle page structure and routing
    - **Custom Hooks:** Extract reusable logic from components
- **Benefits:** Simplicity, better code reuse, easier testing, smaller bundle size

### 2.2 React 18 New Features

**Concurrent Rendering:**
- **Automatic Batching:** Multiple state updates batched automatically (even in promises, timeouts)
- **Transitions:** Use `startTransition` for non-urgent updates
- **Suspense:** Enhanced Suspense for data fetching (with React Query or similar)
- **useDeferredValue:** Defer expensive re-renders

**New Hooks:**
- **useId:** Generate unique IDs for accessibility
- **useTransition:** Mark state updates as transitions
- **useDeferredValue:** Defer expensive computations
- **useSyncExternalStore:** Subscribe to external stores
- **useInsertionEffect:** For CSS-in-JS libraries

**New Root API:**
- Replace `ReactDOM.render()` with `createRoot()`
- Replace `ReactDOM.hydrate()` with `hydrateRoot()`

### 2.3 State Management Strategy

**Local State:**
- Use `useState` for simple component state
- Use `useReducer` for complex state logic
- Keep state close to where it's used

**Shared State:**
- Use Context API for shared state (theme, auth, user preferences)
- Avoid prop drilling with context
- Split contexts by concern (don't create single giant context)

- Use Spring Boot auto-configuration over manual configuration
- Use Spring Boot starters for common functionality
- Use Spring Boot Actuator for health checks and metrics
- Use Spring Data JPA repositories instead of custom DAO layers
- Use Spring's `@Transactional` for transaction management
- Use Spring's exception handling (`@RestControllerAdvice`) over custom error handlers

**Dependency Injection:**

- Use constructor injection exclusively (with `@RequiredArgsConstructor`)
- Avoid field injection (@Autowired on fields)
- Make injected fields final for immutability

**Configuration:**

- Use `application.properties` over `application.yml` unless specified
- Use `@ConfigurationProperties` for grouped configuration
- Externalize environment-specific configuration

---

## 3. Data Access Layer

### 3.1 JPA Configuration

- **Framework:** Spring Data JPA
- **Repository Pattern:**
    - Use Spring Data JPA repositories (extends JpaRepository or CrudRepository)
    - Create custom repository interfaces for domain-specific queries
- **Entity Design:**
    - Use Lombok annotations for boilerplate (@Entity, @Data, @Builder, @NoArgsConstructor,
      @AllArgsConstructor)
    - Consider separating JPA entities from domain models for complex domains
- **Query Strategy:**
    - Prefer derived query methods where possible
    - Use `@Query` with JPQL for complex queries
    - Use native queries sparingly

### 3.2 Transaction Management

- **Approach:** Declarative transactions with `@Transactional`
- **Location:** Service layer methods (never in controllers or repositories)
- **Propagation:** Use appropriate propagation levels (default REQUIRED is usually sufficient)
- **Read-Only:** Mark read-only transactions with `@Transactional(readOnly = true)` for optimization

---

## 4. REST API Layer

### 4.1 Controller Design

- **Annotation:** Use `@RestController` for all REST endpoints
- **Request Mapping:** Use specific HTTP method annotations (@GetMapping, @PostMapping, @PutMapping,
  @DeleteMapping)
- **Path Variables:** Use meaningful names with `@PathVariable`
- **Request Bodies:** Use DTOs with `@RequestBody` and `@Valid`
- **Response Handling:** Return DTOs or ResponseEntity for complex responses

### 4.2 Input Validation

- **Framework:** Jakarta Bean Validation (javax.validation → jakarta.validation)
- **Strategy:** Use validation annotations on DTOs (@NotNull, @NotBlank, @Size, @Valid)
- **Error Handling:** Global exception handler for validation errors

### 4.3 Exception Handling

- **Approach:** Global exception handler using `@RestControllerAdvice`
- **Response Format:** Consistent error response DTOs
- **HTTP Status Codes:** Use appropriate status codes (400, 404, 500, etc.)
- **Logging:** Log exceptions at appropriate levels

---

## 5. Cross-Cutting Concerns

### 5.1 Performance Monitoring

- **Prefer:** Spring Boot Actuator with Micrometer for metrics
- **Alternative:** Custom AOP interceptors only if Actuator is insufficient
- **Metrics:** Track response times, error rates, database query performance

### 5.2 Security

- **Framework:** Spring Security (if authentication/authorization needed)
- **Configuration:** Java-based security configuration
- **CORS:** Configure CORS if needed for cross-origin requests

### 5.3 Health Checks

- **Framework:** Spring Boot Actuator
- **Endpoints:** `/actuator/health`, `/actuator/info`
- **Custom Health Indicators:** Implement custom health checks for external dependencies
- **Ping Endpoint Replacement:** If the application has a custom ping endpoint, it can be removed as Spring Boot Actuator's `/actuator/health` endpoint provides equivalent functionality

---

## 6. Testing Requirements

### 6.1 Unit Testing

- **Framework:** JUnit 5 (Jupiter) with Mockito
- **Migration:** Migrate from JUnit 4 if needed
- **Structure:**
    - Test classes should mirror production class names with `Test` suffix
    - Use `@ExtendWith(MockitoExtension.class)` for Mockito support
    - Mock dependencies using `@Mock` and inject with `@InjectMocks`
    - Use AssertJ or Hamcrest for fluent assertions
- **Best Practices:**
    - Test one behavior per test method
    - Use descriptive test method names (e.g., `shouldReturnUserWhenIdExists()`)
    - Follow Arrange-Act-Assert pattern (no comments to separate this)
    - Avoid testing Spring framework functionality
    - Keep tests focused and isolated

### 6.2 Integration Testing

- **Framework:** Spring Boot Test with Testcontainers
- **Structure:**
    - Use `@SpringBootTest` for full application context tests
    - Use Testcontainers for database and external dependencies
    - Create separate test configuration if needed
- **Database Testing:**
    - Use Testcontainers MySQL for real database testing
    - Prefer real database over H2 in-memory database
    - Use `@Sql` for test data setup if needed
- **Best Practices:**
    - Test full request-response cycles
    - Verify database state changes
    - Test error scenarios and edge cases
    - Ensure test isolation (clean up between tests)
    - Minimize mocking in integration tests

### 6.3 Test Configuration

- **Profile:** Use `application-test.properties` for test-specific configuration
- **Test Profiles:** Use test profiles where appropriate
- **Test Data:** Use test fixtures, builders, or @Sql scripts
- **Cleanup:** Ensure tests are isolated and don't affect each other
- **Mocking Strategy:** Minimize mocking in integration tests, mock external dependencies only

---

## 7. Build Configuration

### 7.1 Gradle Configuration

- **Plugin:** Spring Boot Gradle plugin
- **Packaging:** JAR or WAR based on deployment needs
- **Dependencies:** Use version catalog or Spring Boot BOM
- **Build Tasks:** Ensure build includes tests and validation

**Note:** Deployment configuration (Docker, CI/CD, environment-specific configs) is managed in
separate devops repository.

---

## 8. Post-Migration Cleanup and Optimization

After the main migration is complete, perform these cleanup tasks:

### 8.1 Dependency Cleanup

- Remove all WildFly and Jakarta EE dependencies (`jakarta.jakartaee-api`, `jboss`, etc.)
- Remove unused Spring Boot starters
- Consolidate duplicate dependencies
- Update to use Spring Boot BOM versions consistently
- Remove any compile-time-only dependencies that are no longer needed
- Clean up version catalog if used
- **Verify:** No `jakarta.jakartaee-api`, `jboss`, or WildFly artifacts remain

### 8.2 Code Optimization

- Remove unused imports, classes, methods, and fields
- Remove dead code identified during migration
- Replace custom implementations with Spring Boot built-in features:
    - Custom error handlers → `@RestControllerAdvice`
    - Custom interceptors → Spring AOP or built-in filters
    - Custom configuration → Spring Boot auto-configuration
    - Custom logging → SLF4J with Spring Boot logging
- Simplify configuration by leveraging auto-configuration
- Remove empty or unnecessary configuration files

### 8.3 Logging Optimization

- Consolidate logging configuration in `application.properties`
- Remove custom logging frameworks if Spring Boot logging is sufficient
- Ensure structured logging is properly configured
- Remove duplicate or redundant log statements
- Verify MDC context is properly set up

### 8.4 Test Cleanup

- Ensure all tests pass with Spring Boot Test
- Remove unused test dependencies
- Consolidate test configuration
- Optimize slow integration tests
- Remove flaky or broken tests (document as OBSERVE if business logic unclear)

### 8.5 Configuration Cleanup

- Remove redundant `application.properties` entries
- Consolidate environment-specific configuration
- Remove unused profiles
- Clean up any WildFly-specific configuration files (persistence.xml, web.xml, beans.xml)

### 8.6 Performance Tuning

- Review and optimize HikariCP connection pool settings
- Review JPA fetch strategies and query performance
- Add Spring Cache if beneficial
- Configure actuator endpoints appropriately for production

### 8.7 Cleanup Process Guidelines

- **Incremental:** Work in small increments
- **Verification:** Build and test after each increment
- **Documentation:** Update progress document with cleanup progress
- **Uncertainty:** Mark any uncertainties with `OBSERVE`
- **Caution:** Do not remove code if its purpose is unclear - mark with `OBSERVE` instead

---

## 9. Migration Acceptance Criteria

The migration is complete when:

- [ ] Application starts successfully with React 18
- [ ] All features work correctly
- [ ] All user interactions function as expected
- [ ] All tests pass (unit, component, E2E)
- [ ] No React 16 dependencies remain
- [ ] No class components remain (all functional with hooks)
- [ ] All deprecated patterns removed (UNSAFE_ methods, findDOMNode, etc.)
- [ ] createRoot() is used instead of ReactDOM.render()
- [ ] Build completes successfully
- [ ] No console warnings or errors
- [ ] Performance metrics are maintained or improved
- [ ] Accessibility standards are met
- [ ] Code follows React 18 best practices
- [ ] No technical debt introduced

**Note:** Deployment verification (Docker, Kubernetes, etc.) is handled separately in the devops
repository.

---

## 10. Application-Specific Requirements

[Add any application-specific requirements here, such as:]

- Specific integrations (Elasticsearch, external APIs, etc.)
- Custom business logic requirements
- Performance requirements
- Backward compatibility needs
- Specific security requirements