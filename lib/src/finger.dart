enum Finger {
  rightThumb(1, 'Right Thumb', true),
  rightIndex(2, 'Right Index', true),
  rightMiddle(3, 'Right Middle', true),
  rightRing(4, 'Right Ring', true),
  rightPinky(5, 'Right Pinky', true),
  leftThumb(6, 'Left Thumb', false),
  leftIndex(7, 'Left Index', false),
  leftMiddle(8, 'Left Middle', false),
  leftRing(9, 'Left Ring', false),
  leftPinky(10, 'Left Pinky', false);

  const Finger(this.id, this.label, this.isRight);

  final int id;
  final String label;
  final bool isRight;

  bool get isLeft => !isRight;

  static const all = Finger.values;
  static const rightHand = [
    rightThumb,
    rightIndex,
    rightMiddle,
    rightRing,
    rightPinky,
  ];
  static const leftHand = [
    leftThumb,
    leftIndex,
    leftMiddle,
    leftRing,
    leftPinky,
  ];
}
