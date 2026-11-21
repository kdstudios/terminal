import '../../story_model.dart';
import '../story_kit.dart';

// FREQUENCY FRANK. Paranoid radio enthusiast; wrong about nearly everything,
// right about exactly the thing that matters. He can quote what you found in
// THE LAST TRANSMISSION. World facts: frank.trusted, frank.mocked.

class FrequencyFrank {
  static List<String> greeting(StoryCtx c) {
    final t = c.ending('transmission');
    return [
      if (known(c, 'frank.mocked'))
        'Frank is wearing three hats of foil and does not look at you. “I do not speak to the Laughing Man,” he tells a nearby lamppost, loudly.'
      else if (known(c, 'frank.trusted'))
        'Frank rushes toward you with an enormous pair of headphones round his neck. “It’s you! The only one who listened! I’ve been logging. I’ve got so many logs.”'
      else
        'A man in a colander and four sets of headphones grabs your sleeve. “Frequency Frank. Don’t say your name out loud. They listen to the names.”',
      if (t == 'truth')
        '“You were in the Dentist’s Tower, weren’t you,” he whispers. “You told the truth over the tape. It’s all over the dial. A little girl’s voice saying it was okay.”'
      else if (t == 'answered')
        '“I heard it,” he says. “The woman who answered. Someone finally told her it was okay to stop. That one wasn’t paranoia, that one was grief.”'
      else if (t == 'kept')
        '“Your beacon,” he says, tapping a dial. “It’s still broadcasting. I think it’s a bit lonely.”'
      else if (t == 'silenced')
        '“Dead air,” he says reverently. “One of the loudest silences I’ve ever heard. Nothing since. I check every night.”',
    ];
  }
}
