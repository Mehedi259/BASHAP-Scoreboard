# Implementation Plan: Martial Arts Scoreboard

## Overview

This implementation plan breaks down the martial arts scoreboard application into discrete coding tasks. The application will be built using Flutter/Dart with Provider for state management and SharedPreferences for persistence. The implementation follows a layered architecture: data models → state management → services → UI components → integration.

## Tasks

- [x] 1. Set up project dependencies and base configuration
  - Add `provider` package to pubspec.yaml for state management
  - Add `shared_preferences` package to pubspec.yaml for data persistence
  - Add `fast_check` package to dev_dependencies for property-based testing
  - Create directory structure: `lib/models/`, `lib/state/`, `lib/services/`, `lib/screens/`, `lib/widgets/`
  - _Requirements: Foundation for all subsequent tasks_

- [ ] 2. Implement core data models and enumerations
  - [x] 2.1 Create enumeration types
    - Create `lib/models/enums.dart` with Corner (blue, red), ScoreType (positive, negative), MatchStatus (fresh, active, Thoma, completed), and ResolutionMethod (pointsDecision, advantage, disqualification) enums
    - _Requirements: Foundation for type-safe state management_
  
  - [x] 2.2 Implement CompetitorState model
    - Create `lib/models/competitor_state.dart` with name, positiveScore, negativeScore fields
    - Implement totalScore getter that returns sum of positiveScore and negativeScore
    - Implement copyWith method for immutable updates
    - _Requirements: 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4, 4.10, 4.11_
  
  - [ ]* 2.3 Write unit tests for CompetitorState
    - Test totalScore calculation with various positive and negative score combinations
    - Test totalScore with negative result (negative score > positive score)
    - Test copyWith method preserves unchanged fields
    - _Requirements: 4.10, 4.11_
  
  - [ ]* 2.4 Write property test for CompetitorState total score calculation
    - **Property 12: Total Score Calculation**
    - **Validates: Requirements 4.10, 4.11**
    - Generate random positive and negative scores (0-100)
    - Assert totalScore equals positiveScore + negativeScore for all cases
  
  - [x] 2.5 Implement MatchResult model
    - Create `lib/models/match_result.dart` with winner (Corner), blueCorner (CompetitorState), redCorner (CompetitorState), matchTime (Duration), resolutionMethod (ResolutionMethod) fields
    - Implement toJson and fromJson methods for serialization
    - _Requirements: 7.7, 7.8, 7.9, 8.1-8.8, 11.4, 11.5_
  
  - [ ]* 2.6 Write unit tests for MatchResult serialization
    - Test toJson produces correct JSON structure
    - Test fromJson reconstructs equivalent MatchResult
    - Test round-trip serialization preserves all data
    - _Requirements: 11.4, 11.5_

- [ ] 3. Implement storage service for data persistence
  - [x] 3.1 Create StorageService interface
    - Create `lib/services/storage_service.dart` with abstract class defining getTimerPreference, setTimerPreference, getMatchHistory, and saveMatchResult methods
    - _Requirements: 1.8, 11.1, 11.2, 11.3, 11.4, 11.5_
  
  - [x] 3.2 Implement SharedPreferencesStorageService
    - Create `lib/services/shared_preferences_storage_service.dart` implementing StorageService
    - Implement getTimerPreference returning Duration from stored seconds (default 180)
    - Implement setTimerPreference storing Duration as total seconds
    - Implement getMatchHistory loading JSON list and deserializing MatchResult objects
    - Implement saveMatchResult appending to match history JSON list
    - _Requirements: 1.8, 11.1, 11.2, 11.3, 11.4, 11.5_
  
  - [ ]* 3.3 Write unit tests for SharedPreferencesStorageService
    - Test timer preference storage and retrieval with mock SharedPreferences
    - Test default timer value when no preference exists
    - Test match history serialization and deserialization
    - _Requirements: 11.1, 11.2, 11.3_
  
  - [ ]* 3.4 Write property test for timer persistence round-trip
    - **Property 2: Timer Configuration Persistence Round-Trip**
    - **Validates: Requirements 1.8, 11.1, 11.2**
    - Generate random valid Duration values (0 seconds to 5999 seconds)
    - Save duration to storage, then load it back
    - Assert loaded duration equals original duration

- [ ] 4. Checkpoint - Ensure data layer tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement timer formatting utility
  - [x] 5.1 Create duration formatting function
    - Create `lib/utils/duration_formatter.dart` with formatTimer function
    - Implement logic to convert Duration to "MM:SS" string format
    - Handle edge cases: ensure minutes are clamped to 99, seconds padded to 2 digits
    - _Requirements: 1.1, 8.7, 12.2_
  
  - [ ]* 5.2 Write unit tests for duration formatter
    - Test formatting for 0 seconds returns "00:00"
    - Test formatting for 180 seconds returns "03:00"
    - Test formatting for 5999 seconds returns "99:59"
    - Test formatting handles single-digit minutes and seconds with zero padding
    - _Requirements: 1.1_
  
  - [ ]* 5.3 Write property test for timer display format
    - **Property 1: Timer Display Format**
    - **Validates: Requirements 1.1**
    - Generate random Duration values (0 to 5999 seconds)
    - Format duration and parse result with regex: `^\d{2}:\d{2}$`
    - Assert format matches pattern and values are within valid ranges

- [ ] 6. Implement MatchStateNotifier for centralized state management
  - [x] 6.1 Create MatchStateNotifier class structure
    - Create `lib/state/match_state_notifier.dart` extending ChangeNotifier
    - Define state properties: blueCorner, redCorner (CompetitorState), timerRemaining, timerInitial (Duration), matchState (MatchStatus), advantage (Corner?), timer (Timer?)
    - Inject StorageService via constructor
    - Implement dispose method to cancel timer
    - _Requirements: 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4, 5.6_
  
  - [x] 6.2 Implement timer configuration and persistence
    - Implement loadTimerPreference method calling storage service
    - Implement updateTimerConfig method that updates timerInitial, saves to storage, and notifies listeners
    - Call loadTimerPreference in constructor to initialize timerInitial
    - Apply timer bounds (0 to 5999 seconds) when updating configuration
    - _Requirements: 1.2, 1.8, 11.1, 11.2, 11.3, 12.2, 12.3_
  
  - [ ]* 6.3 Write property test for timer configuration persistence
    - **Property 3: Timer Start From Configured Value**
    - **Validates: Requirements 1.2, 1.4**
    - Generate random timer configuration values (0 to 5999 seconds)
    - Update timer config and verify timerRemaining equals timerInitial
  
  - [x] 6.4 Implement timer start, stop, and tick logic
    - Implement startTimer method that creates Timer.periodic with 1-second interval if not already running
    - Implement stopTimer method that cancels timer and sets timer reference to null
    - Implement private _tickTimer method that decrements timerRemaining by 1 second, notifies listeners, and stops timer at zero
    - Update matchState to active when starting, Thoma when stopping
    - _Requirements: 1.4, 1.5, 1.6, 1.7, 2.2, 2.3_
  
  - [ ]* 6.5 Write unit tests for timer lifecycle
    - Test startTimer transitions matchState from fresh to active
    - Test startTimer begins countdown from configured value
    - Test stopTimer pauses countdown and preserves remaining time
    - Test resuming timer continues from Thoma value
    - Test timer stops automatically when reaching zero
    - _Requirements: 1.4, 1.5, 1.6, 1.7_
  
  - [ ]* 6.6 Write property tests for timer state transitions
    - **Property 4: Timer Pause Preserves Current Value**
    - **Validates: Requirements 1.5**
    - Generate random timer states with various remaining times
    - Start timer, stop timer, verify remaining time unchanged
    - **Property 5: Timer Resume Continues From Thoma Value**
    - **Validates: Requirements 1.6**
    - Generate Thoma timer states, resume and verify countdown continues from Thoma value
  
  - [x] 6.7 Implement competitor name management
    - Implement updateCompetitorName method accepting Corner and String
    - Trim whitespace from input name
    - Use copyWith to update appropriate CompetitorState
    - Notify listeners after update
    - _Requirements: 3.4, 12.5_
  
  - [ ]* 6.8 Write property test for competitor name updates
    - **Property 8: Competitor Name Updates**
    - **Validates: Requirements 3.4, 12.5**
    - Generate random corner and name strings (including whitespace)
    - Update name and verify stored name equals trimmed input
    - **Property 9: Empty Name Fallback**
    - **Validates: Requirements 3.7, 12.4**
    - Generate empty/whitespace-only names, verify display returns default corner name
  
  - [x] 6.9 Implement score increment and decrement
    - Implement incrementScore method accepting Corner and ScoreType
    - Implement decrementScore method accepting Corner and ScoreType with zero lower bound check
    - Use copyWith to update appropriate CompetitorState
    - Notify listeners after score changes
    - _Requirements: 4.6, 4.7, 4.8, 4.9, 12.1_
  
  - [ ]* 6.10 Write property tests for score operations
    - **Property 10: Score Increment**
    - **Validates: Requirements 4.6, 4.8**
    - Generate random corner, score type, and current score value
    - Increment score and verify result equals original + 1
    - **Property 11: Score Decrement With Lower Bound**
    - **Validates: Requirements 4.7, 4.9, 12.1**
    - Generate random scores including zero, decrement and verify lower bound at zero
  
  - [x] 6.11 Implement advantage management
    - Implement setAdvantage method accepting Corner parameter
    - If corner already has advantage, clear advantage (set to null)
    - If opposite corner has advantage, transfer advantage to selected corner
    - If no advantage set, set advantage to selected corner
    - Notify listeners after advantage changes
    - _Requirements: 5.3, 5.4, 5.5, 5.6, 5.7_
  
  - [ ]* 6.12 Write property tests for advantage logic
    - **Property 13: Advantage Mutual Exclusivity**
    - **Validates: Requirements 5.6**
    - Generate match states, verify at most one corner has advantage
    - **Property 14: Advantage Toggle Behavior**
    - **Validates: Requirements 5.4, 5.7**
    - Set advantage for corner C, set again for C, verify cleared
    - Set for C, then set for opposite, verify transferred
    - **Property 15: Advantage Setting From Null**
    - **Validates: Requirements 5.3**
    - Generate states with no advantage, set for corner C, verify only C has advantage
  
  - [x] 6.13 Implement winner determination logic
    - Implement determineWinner method that calculates total scores for both corners
    - If total scores differ, return MatchResult with higher-scoring corner as winner and resolution "pointsDecision"
    - If total scores equal and one corner has advantage, return MatchResult with advantage corner as winner and resolution "advantage"
    - If total scores equal and no advantage, return error result indicating tiebreaker required
    - _Requirements: 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8_
  
  - [ ]* 6.14 Write property tests for winner determination
    - **Property 18: Winner Determination by Score**
    - **Validates: Requirements 7.3, 7.4, 7.7**
    - Generate match states with unequal total scores
    - Determine winner and verify higher score wins with "pointsDecision"
    - **Property 19: Winner Determination by Advantage**
    - **Validates: Requirements 7.5, 7.8**
    - Generate tied states with one advantage set
    - Determine winner and verify advantage holder wins with "advantage" resolution
    - **Property 20: Winner Determination Requires Tiebreaker**
    - **Validates: Requirements 7.6**
    - Generate tied states with no advantage
    - Attempt to determine winner and verify error result
  
  - [x] 6.15 Implement disqualification logic
    - Implement disqualify method accepting Corner parameter
    - Set matchState to completed
    - Return MatchResult with opposing corner as winner and resolution "disqualification"
    - Stop timer if running
    - Notify listeners
    - _Requirements: 6.8, 6.9_
  
  - [ ]* 6.16 Write property test for disqualification
    - **Property 16: Disqualification Opponent Wins**
    - **Validates: Requirements 6.8, 6.9**
    - Generate match states, disqualify corner C
    - Verify opponent declared winner with "disqualification" resolution
  
  - [x] 6.17 Implement match reset logic
    - Implement resetMatch method that returns all state to initial values
    - Reset both competitors to default names ("BLUE CORNER", "RED CORNER") and zero scores
    - Clear advantage (set to null)
    - Reset timerRemaining to timerInitial
    - Set matchState to fresh
    - Cancel timer if running
    - Notify listeners
    - _Requirements: 2.5, 8.10_
  
  - [ ]* 6.18 Write property test for reset behavior
    - **Property 7: Reset Returns to Initial State**
    - **Validates: Requirements 2.5, 8.10**
    - Generate random match states with various scores, names, timer values
    - Reset match and verify all fields return to initial values

- [ ] 7. Checkpoint - Ensure state management tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Implement reusable UI components and dialogs
  - [x] 8.1 Create ScoreCounter widget
    - Create `lib/widgets/score_counter.dart` as StatelessWidget
    - Accept parameters: label (String), score (int), color (Color), onIncrement (callback), onDecrement (callback)
    - Display large score value with provided color
    - Display label text below score
    - Display + and - buttons with appropriate callbacks
    - _Requirements: 4.5, 4.6, 4.7, 4.8, 4.9_
  
  - [x] 8.2 Create DisqualificationDialog
    - Create `lib/widgets/disqualification_dialog.dart` returning AlertDialog
    - Accept parameter: cornerName (String) for displaying which corner is being disqualified
    - Display warning message about immediate match termination
    - Display "CONFIRM DISQUALIFICATION" button with red styling that returns true
    - Display "RETURN TO MATCH" button with outlined styling that returns false
    - _Requirements: 6.3, 6.4, 6.5, 6.6, 6.7_
  
  - [x] 8.3 Create ResetConfirmationDialog
    - Create `lib/widgets/reset_confirmation_dialog.dart` returning AlertDialog
    - Display warning message about clearing all match data
    - Display "CONFIRM RESET" button that returns true
    - Display "CANCEL" button that returns false
    - _Requirements: 2.6_
  
  - [x] 8.4 Create TimerConfigDialog
    - Create `lib/widgets/timer_config_dialog.dart` for adjusting timer value
    - Accept parameter: currentDuration (Duration)
    - Display current timer value in MM:SS format
    - Provide buttons to increase/decrease time by 15-second increments
    - Enforce timer bounds (00:00 to 99:59)
    - Return selected Duration when dialog closed
    - _Requirements: 1.2, 1.3, 12.2, 12.3_

- [ ] 9. Implement main scoreboard screen UI
  - [x] 9.1 Create ScoreboardScreen structure
    - Create `lib/screens/scoreboard_screen.dart` as StatelessWidget
    - Wrap in Consumer<MatchStateNotifier> to access state
    - Implement Scaffold with AppBar and body
    - Use dark navy background color (#0A1628)
    - _Requirements: 9.1, 9.8_
  
  - [ ] 9.2 Implement timer display in AppBar
    - Display timer value in MM:SS format using monospace font in AppBar title
    - Add settings icon button next to timer that opens TimerConfigDialog
    - Call notifier.updateTimerConfig when user confirms new timer value
    - _Requirements: 1.1, 1.2, 1.3, 9.6_
  
  - [ ] 9.3 Implement competitor sections layout
    - Create responsive layout that stacks vertically on narrow screens (<600px) and side-by-side on wider screens
    - Create blue corner section with blue accent color (#0080FF)
    - Create red corner section with red accent color (#FF4444)
    - Each section contains: name input, score counters, advantage button, disqualify button
    - _Requirements: 9.2, 9.3, 9.5, 9.8, 9.9, 10.5, 10.6_
  
  - [ ] 9.4 Implement competitor name input fields
    - Display TextField for blue corner name with blue corner icon
    - Display TextField for red corner name with red corner icon
    - Bind to notifier.blueCorner.name and notifier.redCorner.name
    - Call notifier.updateCompetitorName on text change
    - Use default names when competitor name is empty
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_
  
  - [ ] 9.5 Implement score displays using ScoreCounter widget
    - Display positive score counter for blue corner (blue color)
    - Display negative score counter with "MINUS POINTS" label for blue corner
    - Display positive score counter for red corner (red color)
    - Display negative score counter with "MINUS POINTS" label for red corner
    - Wire increment/decrement callbacks to notifier methods
    - _Requirements: 4.5, 4.6, 4.7, 4.8, 4.9_
  
  - [ ] 9.6 Implement advantage buttons
    - Display advantage button for blue corner
    - Display advantage button for red corner
    - Show visual indicator when corner has advantage
    - Call notifier.setAdvantage on button press
    - _Requirements: 5.1, 5.2, 5.5_
  
  - [ ] 9.7 Implement disqualify buttons with confirmation
    - Display disqualify button for each corner
    - Show DisqualificationDialog when button pressed
    - If user confirms, call notifier.disqualify and navigate to WinnerScreen with result
    - If user cancels, close dialog without changes
    - _Requirements: 6.1, 6.2, 6.3, 6.7, 6.8_
  
  - [ ] 9.8 Implement match control buttons
    - Display Start/Stop button labeled "AKHAE" with green styling
    - Toggle button behavior based on matchState: start when fresh/Thoma, stop when active
    - Call notifier.startTimer or notifier.stopTimer on button press
    - Display reload/refresh button
    - Show ResetConfirmationDialog when reload button pressed
    - If user confirms reset, call notifier.resetMatch
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 9.4_
  
  - [ ] 9.9 Implement "Determine Winner" button
    - Display button at bottom of screen with prominent styling
    - Call notifier.determineWinner on button press
    - If winner determined successfully, navigate to WinnerScreen with MatchResult
    - If tiebreaker required, show error dialog with message "Match is tied. Please assign advantage to determine winner."
    - _Requirements: 7.1, 7.2, 7.6, 7.9, 9.10_
  
  - [x] 9.10 Apply UI styling and theming
    - Use bold, clear fonts for score displays (size 48+)
    - Ensure high contrast text on dark background
    - Apply blue accent to blue corner elements
    - Apply red accent to red corner elements
    - Apply green color to start/stop button
    - Ensure touch targets are at least 48x48 pixels
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 10.8_

- [ ] 10. Implement winner result screen
  - [ ] 10.1 Create WinnerScreen structure
    - Create `lib/screens/winner_screen.dart` as StatelessWidget
    - Accept MatchResult parameter via route arguments
    - Implement Scaffold with centered content layout
    - Use consistent dark navy background
    - _Requirements: 8.1, 8.2_
  
  - [ ] 10.2 Display winner information
    - Display "OFFICIAL RESULT" text at top
    - Display "WINNER" heading
    - Display winner's name in large text (size 36+)
    - Display side indicator badge showing blue or red corner
    - _Requirements: 8.1, 8.2, 8.3, 8.4_
  
  - [ ] 10.3 Display final scores for both competitors
    - Display both competitors' final positive scores with labels
    - Display both competitors' final negative scores with "MINUS POINTS" label
    - Use consistent typography and spacing
    - _Requirements: 8.5, 8.6_
  
  - [ ] 10.4 Display match metadata
    - Display match elapsed time using duration formatter with "MATCH TIME" label
    - Display resolution method (convert enum to display string) with "RESOLUTION PATH" label
    - Format resolution method as "POINTS DECISION", "ADVANTAGE", or "DISQUALIFICATION"
    - _Requirements: 8.7, 8.8_
  
  - [x] 10.5 Implement "New Match" button
    - Display "+ NEW MATCH" button with light styling at bottom of screen
    - On button press, pop navigation route and call notifier.resetMatch
    - _Requirements: 8.9, 8.10_
  
  - [ ]* 10.6 Write property test for winner screen data display
    - **Property 21: Winner Screen Contains Required Data**
    - **Validates: Requirements 8.3, 8.4, 8.5, 8.6, 8.7, 8.8**
    - Generate random MatchResult objects
    - Render WinnerScreen and verify all required fields present in widget tree

- [ ] 11. Implement responsive layout adaptations
  - [ ] 11.1 Add responsive breakpoints
    - Create `lib/utils/responsive_breakpoints.dart` with helper functions
    - Implement isMobile, isTablet, isDesktop based on MediaQuery width
    - Define breakpoints: mobile <600px, tablet 600-1200px, desktop >1200px
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6_
  
  - [ ] 11.2 Apply responsive layouts to ScoreboardScreen
    - Use LayoutBuilder to access constraints
    - Stack competitor sections vertically on mobile (<600px)
    - Display competitor sections side-by-side on tablet and desktop (>=600px)
    - Scale font sizes appropriately for screen size (reduce on mobile)
    - _Requirements: 10.5, 10.6, 10.7_
  
  - [ ] 11.3 Verify touch target sizes
    - Ensure all buttons have minimum 48x48 pixel touch targets
    - Add padding around small interactive elements if needed
    - Test on mobile simulator to verify usability
    - _Requirements: 10.8_

- [ ] 12. Integrate state management with app root
  - [x] 12.1 Update main.dart with Provider setup
    - Import ChangeNotifierProvider and MatchStateNotifier
    - Create StorageService instance
    - Wrap MaterialApp with ChangeNotifierProvider<MatchStateNotifier>
    - Set initial route to ScoreboardScreen
    - Define named routes for ScoreboardScreen and WinnerScreen
    - _Requirements: Foundation for reactive state management across all screens_
  
  - [x] 12.2 Configure app theme
    - Define ThemeData with dark color scheme
    - Set primary color to blue accent (#0080FF)
    - Set error color to red accent (#FF4444)
    - Configure default text themes for consistency
    - _Requirements: 9.1, 9.2, 9.3_

- [ ] 13. Implement input validation and edge case handling
  - [ ] 13.1 Add name length validation
    - Create utility function to truncate names longer than 30 characters for display
    - Preserve full name in storage (use full name in CompetitorState)
    - Display truncated name with ellipsis in UI
    - _Requirements: 12.6_
  
  - [ ]* 13.2 Write property test for name storage and display
    - **Property 22: Name Storage Preserves Full Length**
    - **Validates: Requirements 12.6**
    - Generate random names including very long strings (100+ characters)
    - Update competitor name and verify full name stored in state
    - Verify display shows truncated version for names >30 characters
  
  - [ ] 13.3 Verify timer bounds enforcement
    - Ensure timer config dialog clamps values to 00:00 - 99:59 range
    - Test updateTimerConfig method rejects out-of-range values
    - _Requirements: 12.2, 12.3_
  
  - [ ] 13.4 Verify score decrement at zero boundary
    - Test decrementScore with zero score maintains zero
    - Verify no error or visual feedback shown to user
    - _Requirements: 12.1_

- [ ] 14. Checkpoint - Ensure all UI and integration tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 15. Write integration tests for complete user flows
  - [ ]* 15.1 Test complete match flow with points decision
    - Start match, increment scores for both corners, determine winner by points
    - Verify winner screen displays correct result
    - Verify "New Match" resets application state
    - _Requirements: 1.4, 4.6, 7.3, 7.7, 8.10_
  
  - [ ]* 15.2 Test match flow with advantage tiebreaker
    - Start match, set equal scores for both corners
    - Set advantage for one corner, determine winner
    - Verify winner determined by advantage with correct resolution method
    - _Requirements: 5.3, 7.5, 7.8_
  
  - [ ]* 15.3 Test disqualification flow
    - Start match, trigger disqualification for one corner
    - Confirm disqualification in dialog
    - Verify opponent declared winner with disqualification resolution
    - _Requirements: 6.3, 6.8, 6.9_
  
  - [ ]* 15.4 Test timer lifecycle throughout match
    - Configure timer, start match, pause, resume, let timer reach zero
    - Verify timer stops at zero and match can still be completed
    - _Requirements: 1.4, 1.5, 1.6, 1.7_
  
  - [ ]* 15.5 Test persistence of timer preferences
    - Update timer configuration, restart app (simulate with new notifier instance)
    - Verify timer loads with previously saved configuration
    - _Requirements: 1.8, 11.1, 11.2_

- [x] 16. Final verification and cleanup
  - Run all tests (unit tests and property tests) with `flutter test`
  - Verify app builds successfully for Android with `flutter build apk`
  - Verify app builds successfully for iOS with `flutter build ios` (if on macOS)
  - Verify app builds successfully for desktop platforms
  - Run app on mobile simulator and verify UI responsiveness
  - Run app on desktop and verify layout adapts correctly
  - Check for any unused imports or dead code
  - Verify all lints pass with `flutter analyze`
  - _Requirements: All requirements validated through comprehensive testing_

## Notes

- Tasks marked with `*` are optional testing tasks that can be skipped for faster MVP delivery
- Property-based tests use fast_check library with minimum 100 iterations per property
- Each property test explicitly references the property number from the design document
- Unit tests focus on specific examples and edge cases complementing property tests
- Checkpoints ensure incremental validation at major milestones (data layer, state layer, UI layer)
- Implementation follows layered architecture: models → services → state → UI
- All state management uses Provider pattern with ChangeNotifier for simplicity
- Responsive design breakpoint at 600px ensures usability on mobile and desktop
