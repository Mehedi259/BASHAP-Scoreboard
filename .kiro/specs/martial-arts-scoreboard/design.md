# Design Document: Martial Arts Scoreboard

## Overview

The martial arts scoreboard is a cross-platform Flutter application that provides real-time match management for tournament officials. The application centers on state management of a single match, tracking two competitors (Blue and Red corners), managing a countdown timer, recording positive and negative scores, tracking advantage markers, handling disqualifications, and determining winners based on tournament rules.

The design follows a reactive state management pattern using Flutter's built-in `ChangeNotifier` for simplicity and performance. The application maintains a single source of truth for match state and exposes methods for all match operations. The UI is built with Flutter widgets that rebuild automatically when state changes.

### Design Goals

- **Simplicity**: Single-page UI with all controls visible, minimal navigation
- **Reliability**: Prevent accidental actions through confirmation dialogs
- **Clarity**: High-contrast UI with large typography for quick readability
- **Responsiveness**: Support mobile, tablet, and desktop form factors
- **Persistence**: Save user preferences to avoid reconfiguration

## Architecture

### Layered Architecture

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Widgets: ScoreboardScreen,            │
│   WinnerScreen, Dialogs)                │
└─────────────────────────────────────────┘
                  │
                  ├─ User Actions
                  ├─ State Updates
                  │
┌─────────────────────────────────────────┐
│         State Management Layer          │
│  (MatchStateNotifier: business logic,   │
│   timer management, winner calculation) │
└─────────────────────────────────────────┘
                  │
                  ├─ Read/Write
                  │
┌─────────────────────────────────────────┐
│         Data Layer                      │
│  (SharedPreferences: timer config)      │
└─────────────────────────────────────────┘
```

### State Management Pattern

The application uses **Provider pattern** with `ChangeNotifier`:

- **MatchStateNotifier**: Centralized state holder extending `ChangeNotifier`
- **Provider**: Dependency injection at app root
- **Consumer/Selector**: Widgets rebuild on state changes
- **Immutable state objects**: Score, competitor, and match configuration data

This pattern avoids over-engineering while providing the reactivity needed for real-time score updates and timer countdowns.

### Timer Architecture

The timer uses Dart's `Timer.periodic` for countdown:

```
Timer.periodic(Duration(seconds: 1), (timer) {
  // Decrement remaining time
  // Notify listeners
  // Stop at zero
})
```

The timer reference is held in `MatchStateNotifier` and cancelled/recreated based on start/stop actions. The periodic callback notifies listeners every second, triggering UI rebuilds to display updated time.

## Components and Interfaces

### Core Components

#### 1. MatchStateNotifier

**Responsibility**: Centralized state management and business logic

**State Properties**:
- `blueCorner: CompetitorState` - Blue corner competitor data
- `redCorner: CompetitorState` - Red corner competitor data
- `timerRemaining: Duration` - Current countdown time
- `timerInitial: Duration` - Configured starting time
- `matchState: MatchStatus` - Current match status (fresh, active, Thoma, completed)
- `advantage: Corner?` - Which corner has advantage (null if none)
- `timer: Timer?` - Active timer instance

**Public Methods**:
- `startTimer()` - Begin or resume countdown
- `stopTimer()` - Pause countdown
- `resetMatch()` - Return to fresh state
- `updateTimerConfig(Duration)` - Set initial timer value
- `incrementScore(Corner, ScoreType)` - Add points
- `decrementScore(Corner, ScoreType)` - Remove points
- `setAdvantage(Corner)` - Mark or toggle advantage
- `disqualify(Corner)` - End match via disqualification
- `determineWinner()` - Calculate and return winner
- `updateCompetitorName(Corner, String)` - Change competitor name

**Internal Methods**:
- `_tickTimer()` - Handle periodic countdown
- `_calculateWinner()` - Apply winner determination logic
- `_loadTimerPreference()` - Load from storage
- `_saveTimerPreference()` - Persist to storage

#### 2. ScoreboardScreen

**Responsibility**: Main UI presenting match controls and live scores

**Widget Structure**:
```
Scaffold
├── AppBar (Timer display)
├── Body
│   ├── CompetitorSection (Blue)
│   │   ├── Name input
│   │   ├── Score counters (positive/negative)
│   │   ├── Advantage button
│   │   └── Disqualify button
│   ├── MatchControls (Center)
│   │   ├── Start/Stop button
│   │   └── Reset button
│   ├── CompetitorSection (Red)
│   │   ├── Name input
│   │   ├── Score counters (positive/negative)
│   │   ├── Advantage button
│   │   └── Disqualify button
│   └── DetermineWinnerButton (Bottom)
```

**Interactions**:
- Consumes `MatchStateNotifier` via `Consumer<MatchStateNotifier>`
- Delegates all actions to notifier methods
- Rebuilds on any state change notification
- Displays confirmation dialogs for reset and disqualification

#### 3. WinnerScreen

**Responsibility**: Display match results after determination

**Data Display**:
- Winner name and corner badge
- Final scores for both competitors (positive and negative)
- Match elapsed time
- Resolution method (Points Decision, Advantage, Disqualification)
- "New Match" button to reset

**Navigation**:
- Receives `MatchResult` object via route arguments
- "New Match" button pops route and resets match state

#### 4. Confirmation Dialogs

**DisqualificationDialog**:
- Warning message about immediate match termination
- "CONFIRM DISQUALIFICATION" button (red)
- "RETURN TO MATCH" button (outlined)
- Returns boolean result

**ResetConfirmationDialog**:
- Warning about clearing all match data
- "CONFIRM RESET" button
- "CANCEL" button
- Returns boolean result

### Data Models

#### CompetitorState

```dart
class CompetitorState {
  final String name;
  final int positiveScore;
  final int negativeScore;
  
  int get totalScore => positiveScore + negativeScore;
  
  CompetitorState copyWith({...});
}
```

#### MatchResult

```dart
class MatchResult {
  final Corner winner;
  final CompetitorState blueCorner;
  final CompetitorState redCorner;
  final Duration matchTime;
  final ResolutionMethod resolutionMethod;
}
```

#### Enumerations

```dart
enum Corner { blue, red }
enum ScoreType { positive, negative }
enum MatchStatus { fresh, active, Thoma, completed }
enum ResolutionMethod { pointsDecision, advantage, disqualification }
```

### Interfaces

#### StorageService

**Purpose**: Abstract local storage operations

```dart
abstract class StorageService {
  Future<Duration?> getTimerPreference();
  Future<void> setTimerPreference(Duration duration);
  Future<List<MatchResult>> getMatchHistory();
  Future<void> saveMatchResult(MatchResult result);
}
```

**Implementation**: `SharedPreferencesStorageService`
- Uses `shared_preferences` package
- Stores timer as total seconds (int)
- Serializes match history as JSON list

## Data Models

### State Object Hierarchy

```
MatchStateNotifier
├── CompetitorState (Blue)
│   ├── name: String
│   ├── positiveScore: int
│   ├── negativeScore: int
│   └── totalScore: int (computed)
├── CompetitorState (Red)
│   ├── name: String
│   ├── positiveScore: int
│   ├── negativeScore: int
│   └── totalScore: int (computed)
├── timerRemaining: Duration
├── timerInitial: Duration
├── matchState: MatchStatus
├── advantage: Corner?
└── timer: Timer?
```

### Validation Rules

**Score Constraints**:
- Positive scores: `>= 0`
- Negative scores: `>= 0`
- Total score: `can be negative` (when negative score > positive score)
- Decrement operations blocked at zero

**Timer Constraints**:
- Minimum: `00:00`
- Maximum: `99:59`
- Default: `03:00`
- Adjustment increments: 15 seconds (configurable)

**Name Constraints**:
- Maximum display length: 30 characters (truncated with ellipsis)
- Empty names fall back to "BLUE CORNER" / "RED CORNER"
- Whitespace trimmed on input

### Data Persistence Schema

**SharedPreferences Keys**:
- `timer_preference_seconds`: int (default 180)
- `match_history`: JSON-encoded list of match results

**MatchResult JSON Structure**:
```json
{
  "winner": "blue" | "red",
  "blueCorner": {
    "name": "string",
    "positiveScore": 0,
    "negativeScore": 0
  },
  "redCorner": {
    "name": "string",
    "positiveScore": 0,
    "negativeScore": 0
  },
  "matchTimeSeconds": 0,
  "resolutionMethod": "pointsDecision" | "advantage" | "disqualification"
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, several properties were identified as redundant or could be combined:

- **Score initialization (4.1-4.4)**: Can be combined into a single property about initial match state
- **Increment/decrement for positive vs negative scores (4.6-4.9)**: Same underlying behavior, can be unified
- **Winner determination by score (7.3, 7.4)**: Can be combined - highest total score wins
- **Reset behavior (2.5, 8.10)**: Same property - reset returns to known initial state
- **Timer persistence (1.8, 11.1, 11.2)**: Single round-trip property covers save and load
- **Display properties (8.3-8.8)**: These all test that winner screen rendering contains required data - can be verified as part of testing but are UI-focused

The following properties represent the unique, non-redundant correctness guarantees:

### Property 1: Timer Display Format

*For any* duration value, formatting it for timer display should produce a string in "MM:SS" format where MM is minutes (00-99) and SS is seconds (00-59).

**Validates: Requirements 1.1**

### Property 2: Timer Configuration Persistence Round-Trip

*For any* valid duration value (00:00 to 99:59), saving the timer preference to storage and then loading it should return an equivalent duration value.

**Validates: Requirements 1.8, 11.1, 11.2**

### Property 3: Timer Start From Configured Value

*For any* initial timer configuration value, starting the timer should begin countdown from that exact value.

**Validates: Requirements 1.2, 1.4**

### Property 4: Timer Pause Preserves Current Value

*For any* running timer state with remaining time T, stopping the timer should preserve the remaining time at T without further countdown.

**Validates: Requirements 1.5**

### Property 5: Timer Resume Continues From Thoma Value

*For any* Thoma timer state with remaining time T, resuming the timer should continue countdown from time T.

**Validates: Requirements 1.6**

### Property 6: Match State Transitions on Start/Stop

*For any* match in fresh or Thoma state, starting should transition to active state; *for any* match in active state, stopping should transition to Thoma state.

**Validates: Requirements 2.2, 2.3**

### Property 7: Reset Returns to Initial State

*For any* match state (regardless of scores, names, timer, advantage), resetting should return all fields to their initial values: scores to zero, names to defaults, advantage cleared, timer to configured value, and match state to fresh.

**Validates: Requirements 2.5, 8.10**

### Property 8: Competitor Name Updates

*For any* match state and any valid name string, updating a competitor's name should result in that exact name (after trimming) being stored and retrievable.

**Validates: Requirements 3.4, 12.5**

### Property 9: Empty Name Fallback

*For any* competitor name that is empty or contains only whitespace, the display name should fall back to the default corner name ("BLUE CORNER" or "RED CORNER").

**Validates: Requirements 3.7, 12.4**

### Property 10: Score Increment

*For any* competitor corner, score type (positive or negative), and current score value S, incrementing should result in score value S+1.

**Validates: Requirements 4.6, 4.8**

### Property 11: Score Decrement With Lower Bound

*For any* competitor corner, score type (positive or negative), and current score value S > 0, decrementing should result in score value S-1; when S = 0, decrementing should maintain S = 0.

**Validates: Requirements 4.7, 4.9, 12.1 (edge case)**

### Property 12: Total Score Calculation

*For any* competitor with positive score P and negative score N, the total score should equal P + N (allowing negative totals when N > P).

**Validates: Requirements 4.10, 4.11 (edge case)**

### Property 13: Advantage Mutual Exclusivity

*For any* match state, at most one competitor can have advantage marked; both corners cannot have advantage simultaneously, and advantage can be null (neither has it).

**Validates: Requirements 5.6**

### Property 14: Advantage Toggle Behavior

*For any* match state where competitor C has advantage, setting advantage for C again should clear the advantage (toggle off); setting advantage for the opposing competitor should transfer advantage to them.

**Validates: Requirements 5.4, 5.7**

### Property 15: Advantage Setting From Null

*For any* match state where no competitor has advantage, setting advantage for corner C should result in exactly C having advantage and the opponent not having it.

**Validates: Requirements 5.3**

### Property 16: Disqualification Opponent Wins

*For any* match state, disqualifying corner C should result in a match outcome where the opposing corner is declared winner with resolution method "DISQUALIFICATION".

**Validates: Requirements 6.8, 6.9**

### Property 17: Cancel Disqualification Preserves State

*For any* match state S, initiating then canceling disqualification should result in state S remaining completely unchanged.

**Validates: Requirements 6.7**

### Property 18: Winner Determination by Score

*For any* match state where blue total score ≠ red total score, determining the winner should declare the corner with the higher total score as winner with resolution method "POINTS DECISION".

**Validates: Requirements 7.3, 7.4, 7.7**

### Property 19: Winner Determination by Advantage

*For any* match state where blue total score = red total score and exactly one corner has advantage, determining the winner should declare the corner with advantage as winner with resolution method "ADVANTAGE".

**Validates: Requirements 7.5, 7.8**

### Property 20: Winner Determination Requires Tiebreaker

*For any* match state where blue total score = red total score and neither corner has advantage, attempting to determine winner should result in an error indicating a tiebreaker is required.

**Validates: Requirements 7.6**

### Property 21: Winner Screen Contains Required Data

*For any* match result, the winner screen rendering should contain: winner name, winner corner indicator, both competitors' positive scores, both competitors' negative scores, match time in MM:SS format, and resolution method.

**Validates: Requirements 8.3, 8.4, 8.5, 8.6, 8.7, 8.8**

### Property 22: Name Storage Preserves Full Length

*For any* competitor name string, storing the name should preserve the complete original string (after trimming), even if the display truncates names longer than 30 characters.

**Validates: Requirements 12.6**

### Edge Cases (Handled by Property Test Generators)

The following edge cases will be explicitly covered in property test generators:

- **Timer reaches zero (1.7)**: Generator should include duration values at and near zero
- **Score at zero boundary (12.1)**: Generator should include zero score values
- **Timer bounds (12.2, 12.3)**: Generator should include values at 00:00 and 99:59
- **Negative total scores (4.11)**: Generator should create states where negative score > positive score

## Error Handling

### Error Categories and Responses

#### 1. User Input Validation Errors

**Score Decrement Below Zero**:
- **Detection**: Before applying decrement operation
- **Response**: Silently ignore (maintain score at zero, no error message)
- **Rationale**: Prevents user frustration during rapid clicking

**Timer Out of Bounds**:
- **Detection**: When user adjusts timer configuration
- **Response**: Clamp to valid range (00:00 to 99:59) silently
- **Rationale**: Maintains valid state without interrupting workflow

**Name Length Validation**:
- **Detection**: On name input
- **Response**: Truncate display with ellipsis, preserve full name in storage
- **Rationale**: Ensures UI readability while preserving data integrity

#### 2. Match State Errors

**Winner Determination Without Tiebreaker**:
- **Detection**: When calculating winner with tied scores and no advantage
- **Response**: Show error dialog: "Match is tied. Please assign advantage to determine winner."
- **Action**: Return user to match screen to set advantage
- **Rationale**: Explicit guidance for resolving ambiguous state

**Invalid State Transitions**:
- **Detection**: Attempting operations in wrong match state (e.g., starting already-active timer)
- **Response**: Silently ignore or treat as no-op
- **Rationale**: Prevents race conditions from user double-clicking

#### 3. Persistence Errors

**Storage Write Failure**:
- **Detection**: Exception during SharedPreferences.setInt/setString
- **Response**: Log error, continue operation without crashing
- **Fallback**: Use in-memory state, lose persistence until next successful write
- **User Notification**: Optional toast message "Failed to save preferences"

**Storage Read Failure**:
- **Detection**: Exception during SharedPreferences.get operations or null return
- **Response**: Use default values (timer: 03:00)
- **Logging**: Record error for debugging
- **User Impact**: None (seamless fallback)

#### 4. Timer Management Errors

**Timer Callback Exception**:
- **Detection**: Exception in Timer.periodic callback
- **Response**: Cancel timer, set match state to Thoma, log error
- **Recovery**: User can restart timer manually
- **Prevention**: Defensive coding in tick handler

### Error Recovery Strategies

**Reset as Universal Recovery**:
- The reset button serves as a catch-all recovery mechanism
- Users can always return to known-good state via reset
- Confirmation dialog prevents accidental resets

**State Validation on Critical Operations**:
- Before determining winner: validate both competitors have valid scores
- Before disqualification: confirm match is not already completed
- Before timer operations: verify timer instance is in expected state

**Graceful Degradation**:
- If persistence fails, application continues with in-memory state
- If timer fails, user can still manually determine winner
- If rendering fails, errors don't propagate to crash the app

### Logging Strategy

**Development Mode**:
- Log all state transitions
- Log all score changes
- Log timer start/stop/reset operations
- Log persistence operations

**Production Mode**:
- Log only errors and exceptions
- Include match state snapshot in error logs
- Respect user privacy (no PII in logs)

## Testing Strategy

### Dual Testing Approach

This application will employ both **unit testing** and **property-based testing** to ensure comprehensive correctness coverage. These approaches are complementary:

- **Unit tests** verify specific examples, edge cases, and integration points
- **Property tests** verify universal properties across randomly generated inputs

Together, they provide confidence that the system behaves correctly across the entire input space.

### Property-Based Testing

**Library**: We will use the **fast_check** Dart package (Dart's most mature PBT library) for property-based testing.

**Configuration**:
- Each property test will run a minimum of **100 iterations**
- Each test will include a comment tag: `// Feature: martial-arts-scoreboard, Property N: [property statement]`
- Generators will be designed to cover edge cases (zero scores, boundary timer values, empty names)

**Property Test Structure**:

```dart
// Feature: martial-arts-scoreboard, Property 12: Total Score Calculation
test('total score equals positive plus negative for any score values', () {
  fc.assert(
    fc.property(
      fc.integer(min: 0, max: 100), // positive score
      fc.integer(min: 0, max: 100), // negative score
      (positive, negative) {
        final competitor = CompetitorState(
          name: "Test",
          positiveScore: positive,
          negativeScore: negative,
        );
        expect(competitor.totalScore, equals(positive + negative));
      },
    ),
    numRuns: 100,
  );
});
```

**Custom Generators**:

- `arbitraryDuration()`: Generate valid Duration values (0 to 99:59)
- `arbitraryMatchState()`: Generate random complete match states
- `arbitraryCompetitorName()`: Generate names including edge cases (empty, whitespace, very long)
- `arbitraryCorner()`: Generate Corner.blue or Corner.red
- `arbitraryScoreType()`: Generate ScoreType.positive or ScoreType.negative

### Unit Testing

**Focus Areas**:

1. **Specific Examples**:
   - Initial state has correct default values
   - Timer displays "03:00" for 3-minute duration
   - Empty names display as "BLUE CORNER" / "RED CORNER"

2. **Edge Cases**:
   - Decrementing score at zero maintains zero
   - Timer reaching 00:00 stops countdown
   - Name truncation at 30 characters displays ellipsis

3. **Integration Points**:
   - MatchStateNotifier properly notifies listeners on state changes
   - Navigation to WinnerScreen includes correct MatchResult
   - Reset confirmation dialog returns correct boolean

4. **UI Interactions**:
   - Buttons are enabled/disabled based on match state
   - Dialogs display correct text and styling
   - Layout adapts to different screen widths

**Test Organization**:

```
test/
├── models/
│   ├── competitor_state_test.dart
│   ├── match_result_test.dart
│   └── enums_test.dart
├── state/
│   ├── match_state_notifier_test.dart
│   └── match_state_notifier_property_test.dart
├── services/
│   ├── storage_service_test.dart
│   └── storage_service_property_test.dart
├── widgets/
│   ├── scoreboard_screen_test.dart
│   ├── winner_screen_test.dart
│   └── dialogs_test.dart
└── integration/
    └── match_flow_test.dart
```

### Test Coverage Goals

- **Property tests**: Cover all 22 correctness properties
- **Unit tests**: Cover specific examples, edge cases, and UI interactions
- **Integration tests**: Cover complete user flows (start match → score points → determine winner → reset)
- **Code coverage target**: 80%+ on business logic (state management and calculations)

### Testing Tools

- **flutter_test**: Built-in Flutter testing framework
- **fast_check**: Property-based testing library
- **mockito**: Mocking for storage service in tests
- **golden_toolkit**: Screenshot testing for UI components (optional)

### Continuous Validation

Tests will be run:
- On every code change (pre-commit hook)
- In CI/CD pipeline before merge
- As part of release verification process

Property tests with 100 iterations provide strong confidence in correctness across the input space while remaining fast enough for frequent execution.

