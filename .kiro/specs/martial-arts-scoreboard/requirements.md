# Requirements Document

## Introduction

This document specifies the requirements for a martial arts tournament scoreboard application built with Flutter for both mobile and desktop platforms. The application manages fights between two competitors, tracks scores in real-time using positive and negative point systems, manages match timing, and determines winners based on multiple criteria including points, advantage, and disqualification.

## Glossary

- **Application**: The martial arts scoreboard Flutter application
- **Match**: A single competition bout between two competitors
- **Timer**: The countdown clock that tracks match duration
- **Blue_Corner**: The competitor assigned to the blue side
- **Red_Corner**: The competitor assigned to the red side
- **Competitor**: A fighter participating in a match (either Blue_Corner or Red_Corner)
- **Positive_Score**: Points awarded to a competitor for successful techniques
- **Negative_Score**: Penalty points deducted from a competitor for rule violations
- **Total_Score**: The sum of Positive_Score and Negative_Score for a competitor
- **Advantage**: A tiebreaker indicator marking which competitor scored first
- **Disqualification**: Immediate match termination awarding victory to the opponent
- **Winner_Screen**: The result display showing match outcome and final scores
- **Match_State**: The current condition of the application (fresh, active, Thoma, completed)
- **User**: The tournament official operating the application

## Requirements

### Requirement 1: Timer Management

**User Story:** As a tournament official, I want to control match timing with a configurable countdown timer, so that I can enforce time limits according to tournament rules.

#### Acceptance Criteria

1. THE Application SHALL display a countdown timer in MM:SS format at the top of the main screen
2. THE Application SHALL allow the User to configure the initial timer value before match start
3. WHEN the User clicks the settings icon next to the Timer, THE Application SHALL provide controls to increase or decrease the time value
4. WHEN the User clicks the Start button, THE Application SHALL begin counting down from the configured time at 1-second intervals
5. WHEN the User clicks the Stop button while the Timer is running, THE Application SHALL pause the countdown
6. WHEN the User clicks the Start button while the Timer is Thoma, THE Application SHALL resume countdown from the Thoma value
7. WHEN the Timer reaches 00:00, THE Application SHALL stop the countdown and emit a completion signal
8. THE Application SHALL persist the User's preferred timer configuration using local storage

### Requirement 2: Match Control

**User Story:** As a tournament official, I want to start, stop, and reset matches, so that I can control the flow of competition.

#### Acceptance Criteria

1. THE Application SHALL display a Start/Stop button labeled "AKHAE" with green styling
2. WHEN the User clicks the Start/Stop button and the Match_State is fresh or Thoma, THE Application SHALL change the Match_State to active and start the Timer
3. WHEN the User clicks the Start/Stop button and the Match_State is active, THE Application SHALL change the Match_State to Thoma and stop the Timer
4. THE Application SHALL display a Reload/Refresh button on the main screen
5. WHEN the User clicks the Reload/Refresh button, THE Application SHALL reset all scores to zero, clear both competitor names to defaults, remove advantage markers, reset the Timer, and return Match_State to fresh
6. WHEN the User clicks the Reload/Refresh button, THE Application SHALL display a confirmation dialog before resetting

### Requirement 3: Competitor Identity Management

**User Story:** As a tournament official, I want to enter and edit competitor names, so that match results correctly identify participants.

#### Acceptance Criteria

1. THE Application SHALL display two name input fields, one for Blue_Corner and one for Red_Corner
2. THE Application SHALL initialize the Blue_Corner name field with default text "BLUE CORNER"
3. THE Application SHALL initialize the Red_Corner name field with default text "RED CORNER"
4. THE Application SHALL allow the User to edit competitor names at any time during a Match
5. THE Application SHALL display a visual icon indicating the Blue_Corner side using blue styling
6. THE Application SHALL display a visual icon indicating the Red_Corner side using red styling
7. WHEN a competitor name is empty, THE Application SHALL use the default corner name in all displays

### Requirement 4: Score Tracking

**User Story:** As a tournament official, I want to track positive and negative scores for each competitor, so that I can accurately record match performance.

#### Acceptance Criteria

1. THE Application SHALL maintain a Positive_Score counter for Blue_Corner initialized to zero
2. THE Application SHALL maintain a Negative_Score counter for Blue_Corner initialized to zero
3. THE Application SHALL maintain a Positive_Score counter for Red_Corner initialized to zero
4. THE Application SHALL maintain a Negative_Score counter for Red_Corner initialized to zero
5. THE Application SHALL display each score counter with large, high-contrast typography
6. WHEN the User clicks the plus button for a Positive_Score counter, THE Application SHALL increment that Positive_Score by 1
7. WHEN the User clicks the minus button for a Positive_Score counter and the score is greater than zero, THE Application SHALL decrement that Positive_Score by 1
8. WHEN the User clicks the plus button for a Negative_Score counter, THE Application SHALL increment that Negative_Score by 1
9. WHEN the User clicks the minus button for a Negative_Score counter and the score is greater than zero, THE Application SHALL decrement that Negative_Score by 1
10. THE Application SHALL calculate Total_Score for each Competitor as the sum of their Positive_Score and Negative_Score
11. THE Application SHALL allow negative Total_Score values when Negative_Score exceeds Positive_Score

### Requirement 5: Advantage Tracking

**User Story:** As a tournament official, I want to mark which competitor scored first, so that I have a tiebreaker if the match ends in a draw.

#### Acceptance Criteria

1. THE Application SHALL provide an Advantage button for Blue_Corner
2. THE Application SHALL provide an Advantage button for Red_Corner
3. WHEN the User clicks an Advantage button and no Advantage is currently marked, THE Application SHALL mark that Competitor as having Advantage
4. WHEN the User clicks an Advantage button for a Competitor who already has Advantage marked, THE Application SHALL remove the Advantage marker
5. THE Application SHALL display a visual indicator when a Competitor has Advantage marked
6. THE Application SHALL allow only one Competitor to have Advantage marked at any time
7. WHEN the User clicks an Advantage button for a Competitor and the opposing Competitor has Advantage, THE Application SHALL transfer the Advantage marker to the selected Competitor

### Requirement 6: Disqualification Process

**User Story:** As a tournament official, I want to disqualify a competitor with confirmation, so that I can enforce rules while preventing accidental disqualifications.

#### Acceptance Criteria

1. THE Application SHALL provide a Disqualify button for Blue_Corner
2. THE Application SHALL provide a Disqualify button for Red_Corner
3. WHEN the User clicks a Disqualify button, THE Application SHALL display a confirmation dialog
4. THE Application SHALL include warning text in the disqualification dialog explaining that the action will terminate the Match immediately and award victory to the opponent
5. THE Application SHALL display "CONFIRM DISQUALIFICATION" button with red styling in the dialog
6. THE Application SHALL display "RETURN TO MATCH" button with outlined styling in the dialog
7. WHEN the User clicks "RETURN TO MATCH", THE Application SHALL close the dialog and return to the Match without changes
8. WHEN the User clicks "CONFIRM DISQUALIFICATION", THE Application SHALL immediately terminate the Match, mark the opposing Competitor as winner, and navigate to the Winner_Screen
9. WHEN a disqualification is confirmed, THE Application SHALL set the resolution method to "DISQUALIFICATION"

### Requirement 7: Winner Determination

**User Story:** As a tournament official, I want to calculate and declare the match winner based on scores and tiebreaker rules, so that results are determined consistently and fairly.

#### Acceptance Criteria

1. THE Application SHALL display a "DETERMINE WINNER" button at the bottom of the main screen
2. WHEN the User clicks "DETERMINE WINNER", THE Application SHALL calculate Total_Score for both competitors
3. WHEN the User clicks "DETERMINE WINNER" and Blue_Corner Total_Score is greater than Red_Corner Total_Score, THE Application SHALL declare Blue_Corner as winner
4. WHEN the User clicks "DETERMINE WINNER" and Red_Corner Total_Score is greater than Blue_Corner Total_Score, THE Application SHALL declare Red_Corner as winner
5. WHEN the User clicks "DETERMINE WINNER" and both Total_Score values are equal and one Competitor has Advantage marked, THE Application SHALL declare the Competitor with Advantage as winner
6. WHEN the User clicks "DETERMINE WINNER" and both Total_Score values are equal and no Competitor has Advantage marked, THE Application SHALL display an error message indicating a tiebreaker is required
7. WHEN a winner is determined by Total_Score difference, THE Application SHALL set the resolution method to "POINTS DECISION"
8. WHEN a winner is determined by Advantage, THE Application SHALL set the resolution method to "ADVANTAGE"
9. WHEN the User clicks "DETERMINE WINNER", THE Application SHALL navigate to the Winner_Screen displaying the match results

### Requirement 8: Winner Result Display

**User Story:** As a tournament official, I want to view comprehensive match results, so that I can verify the outcome and record official results.

#### Acceptance Criteria

1. THE Application SHALL display "OFFICIAL RESULT" text at the top of the Winner_Screen
2. THE Application SHALL display "WINNER" heading on the Winner_Screen
3. THE Application SHALL display the winner's name in large text on the Winner_Screen
4. THE Application SHALL display a side indicator badge showing whether the winner is Blue_Corner or Red_Corner
5. THE Application SHALL display both competitors' final Positive_Score values on the Winner_Screen
6. THE Application SHALL display both competitors' final Negative_Score values with label "MINUS POINTS" on the Winner_Screen
7. THE Application SHALL display match elapsed time in MM:SS format with label "MATCH TIME" on the Winner_Screen
8. THE Application SHALL display the resolution method ("POINTS DECISION", "DISQUALIFICATION", or "ADVANTAGE") with label "RESOLUTION PATH" on the Winner_Screen
9. THE Application SHALL display a "+ NEW MATCH" button with light styling on the Winner_Screen
10. WHEN the User clicks "+ NEW MATCH", THE Application SHALL reset the application to fresh Match_State as if the Reload button was clicked

### Requirement 9: User Interface Styling

**User Story:** As a tournament official, I want a clear, high-contrast interface, so that I can quickly read scores and make decisions during fast-paced matches.

#### Acceptance Criteria

1. THE Application SHALL use dark navy background color (approximately #0A1628) for the main screen
2. THE Application SHALL use blue accent color (approximately #0080FF) for Blue_Corner visual elements
3. THE Application SHALL use red accent color (approximately #FF4444) for Red_Corner visual elements
4. THE Application SHALL use green color for the Start/Stop button
5. THE Application SHALL use bold, clear fonts for score displays
6. THE Application SHALL use monospace font for the Timer display
7. THE Application SHALL ensure text has high contrast against background colors for readability
8. THE Application SHALL display Blue_Corner and Red_Corner sections in vertical split layout on the main screen
9. THE Application SHALL center the Timer and match control buttons horizontally
10. THE Application SHALL position the "DETERMINE WINNER" button at the bottom of the main screen

### Requirement 10: Responsive Layout

**User Story:** As a tournament official, I want the application to work on phones, tablets, and desktop computers, so that I can use whatever device is available at the tournament venue.

#### Acceptance Criteria

1. THE Application SHALL display correctly on mobile devices in portrait orientation
2. THE Application SHALL display correctly on mobile devices in landscape orientation
3. THE Application SHALL display correctly on tablet devices
4. THE Application SHALL display correctly on desktop computers with wide screens
5. WHEN the screen width is below 600 pixels, THE Application SHALL use a vertical stacking layout for competitor sections
6. WHEN the screen width is above 600 pixels, THE Application SHALL use a side-by-side layout for competitor sections where appropriate
7. THE Application SHALL scale font sizes appropriately for different screen sizes
8. THE Application SHALL maintain touch target sizes of at least 48x48 pixels for all interactive elements

### Requirement 11: Data Persistence

**User Story:** As a tournament official, I want my timer preferences saved, so that I don't need to reconfigure the timer for each match.

#### Acceptance Criteria

1. THE Application SHALL store the User's timer configuration value in local device storage
2. WHEN the Application launches, THE Application SHALL load the previously saved timer configuration from local storage
3. WHEN no previously saved timer configuration exists, THE Application SHALL use a default value of 03:00
4. WHERE match history recording is implemented, THE Application SHALL store completed match results in local device storage
5. WHERE match history recording is implemented, THE Application SHALL include competitor names, final scores, resolution method, and match time in stored results

### Requirement 12: Input Validation

**User Story:** As a tournament official, I want the application to handle edge cases gracefully, so that I can focus on managing the match without technical issues.

#### Acceptance Criteria

1. WHEN the User attempts to decrement a score below zero, THE Application SHALL maintain the score at zero and provide no visual feedback
2. WHEN the Timer value is manually adjusted to exceed 99:59, THE Application SHALL cap the Timer at 99:59
3. WHEN the Timer value is manually adjusted to below 00:00, THE Application SHALL set the Timer to 00:00
4. WHEN both competitor names are empty, THE Application SHALL use "BLUE CORNER" and "RED CORNER" in all displays
5. THE Application SHALL trim whitespace from competitor name inputs before display and storage
6. WHEN a competitor name exceeds 30 characters, THE Application SHALL truncate the display with ellipsis while preserving the full name in storage

