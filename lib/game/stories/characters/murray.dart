import '../../story_model.dart';
import '../story_kit.dart';

// MURRAY THE MAGNIFICENT, terrible travelling magician. His mutant rabbit,
// Professor Nibbles, is the real brains of the act. World facts:
// murray.rabbit_trusted, murray.humiliated, murray.helped.

class Murray {
  static List<String> greeting(StoryCtx c) {
    if (known(c, 'murray.helped')) {
      return [
        'Murray sweeps off his hat, and a pigeon falls out, looking furious. “My lucky assistant returns! The Professor has not stopped talking about you.” The rabbit, on his shoulder, does not move, but you suspect it is taking notes.',
      ];
    }
    if (known(c, 'murray.humiliated')) {
      return [
        'Murray sees you and tries to vanish. He does this by standing behind a lamppost that is thinner than he is. “I am not here,” he says. “This is a very advanced trick.”',
      ];
    }
    return [
      'A man in a sequinned cape bows so deeply he loses his hat. “Murray the Magnificent! Illusionist! Escapologist! Occasionally, a cat person!” On his shoulder, a rabbit the size of a toddler regards you with sad intelligence.',
    ];
  }
}
