import '../../story_model.dart';
import '../story_kit.dart';

// GARY, the wasteland survivor whose shoes keep disappearing. NOT the same
// person as any of the bunker Garys in THE GARYS (they only share a name).
// World facts: gary.helped, gary.teased, gary.lied, gary.refused,
// gary.shoes_solved, gary.ridiculous (his follow-up problems).

class Gary {
  static String mood(StoryCtx c) {
    if (known(c, 'gary.helped')) return 'helped';
    if (known(c, 'gary.lied')) return 'lied';
    if (known(c, 'gary.teased')) return 'teased';
    if (known(c, 'gary.refused')) return 'refused';
    return 'new';
  }

  static List<String> greeting(StoryCtx c) {
    switch (mood(c)) {
      case 'helped':
        return [
          'Gary spots you from fifty metres and waves with both arms. He is wearing one boot, one slipper and an expression of pure joy. “My friend! The one who believed me! Come, come, I have a new problem and you are the only person I trust with it!”',
        ];
      case 'lied':
        return [
          'Gary lights up like a dashboard. “It’s you! You told me about the mole-rat cartel! I’ve been taking notes! I have a cork board! I have string! Please do not tell me it was not true. I have bought a lot of string.”',
        ];
      case 'teased':
        return [
          'Gary sees you and does a very visible, very bad impression of a man who is not hiding behind a bin. “Oh. It’s you. The laughing one. I am not angry. I am a calm person. I am calm and I am holding a net.”',
        ];
      case 'refused':
        return [
          'Gary squints. “Do I know you? I think I know you. You were the one who said it wasn’t your problem.” He sighs, without bitterness. “Fair. It really is mine. Still. Hello.”',
        ];
      default:
        return [
          'A friendly man in odd socks beams at you. “Hello! I am Gary! I am having a bit of a day. Actually, a bit of a year. Do you happen to have seen a shoe?”',
        ];
    }
  }
}
