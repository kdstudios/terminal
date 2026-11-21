import '../../story_model.dart';
import '../story_kit.dart';

// GRANDMA GRIM. Looks like a sweet old lady. Has a shotgun called Dolores.
// World facts: grim.respect (earned it), grim.insulted, grim.friend.

class GrandmaGrim {
  static List<String> greeting(StoryCtx c) {
    if (known(c, 'grim.friend')) {
      return [
        'Grandma Grim pats the chair beside her without looking up from her knitting. “Sit, dear. Dolores likes you, and Dolores likes almost nobody.” The shotgun, leaning on the arm of the chair, does not say anything. It is very polite about it.',
      ];
    }
    if (known(c, 'grim.insulted')) {
      return [
        'Grandma Grim looks at you for a long moment. “I remember you. You were rude to my cardigan.” Somewhere behind you, a bolt slides home. “I’ve had the afternoon to think about that.”',
      ];
    }
    return [
      'A tiny old woman in a lilac cardigan sits knitting on a porch. She smiles warmly. Across her knees lies a very large, very well-oiled shotgun. “Hello, dear. Don’t mind Dolores. Dolores is just resting.”',
    ];
  }
}
