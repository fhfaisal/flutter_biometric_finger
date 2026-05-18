/// Represents a finger on the human hand for biometric scanning.
enum Finger {
  /// The thumb on the right hand.
  rightThumb(1, 'Right Thumb', true),
  /// The index finger on the right hand.
  rightIndex(2, 'Right Index', true),
  /// The middle finger on the right hand.
  rightMiddle(3, 'Right Middle', true),
  /// The ring finger on the right hand.
  rightRing(4, 'Right Ring', true),
  /// The pinky finger on the right hand.
  rightPinky(5, 'Right Pinky', true),
  /// The thumb on the left hand.
  leftThumb(6, 'Left Thumb', false),
  /// The index finger on the left hand.
  leftIndex(7, 'Left Index', false),
  /// The middle finger on the left hand.
  leftMiddle(8, 'Left Middle', false),
  /// The ring finger on the left hand.
  leftRing(9, 'Left Ring', false),
  /// The pinky finger on the left hand.
  leftPinky(10, 'Left Pinky', false);

  /// Constructor for Finger.
  const Finger(this.id, this.label, this.isRight);

  /// The unique integer identifier of the finger.
  final int id;

  /// The user-friendly label/name of the finger.
  final String label;

  /// Returns true if the finger belongs to the right hand.
  final bool isRight;

  /// Returns true if the finger belongs to the left hand.
  bool get isLeft => !isRight;

  /// A list of all 10 fingers.
  static const all = Finger.values;

  /// A list of all fingers on the right hand.
  static const rightHand = [
    rightThumb,
    rightIndex,
    rightMiddle,
    rightRing,
    rightPinky,
  ];

  /// A list of all fingers on the left hand.
  static const leftHand = [
    leftThumb,
    leftIndex,
    leftMiddle,
    leftRing,
    leftPinky,
  ];
}
