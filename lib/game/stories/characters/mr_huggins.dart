import '../../story_model.dart';
import '../story_kit.dart';

// MR. HUGGINS, hotel hospitality robot. Cheerful, apologetic, tireless, and
// running a hotel with no roof. World facts: huggins.checked_in,
// huggins.five_stars, huggins.complained.

class MrHuggins {
  static List<String> greeting(StoryCtx c) {
    if (known(c, 'huggins.five_stars')) {
      return [
        '“Welcome BACK, esteemed guest!” Mr. Huggins bows with a hiss of tired servos. “Your five-star review is framed in the lobby, beside the place where the lobby used to be.”',
      ];
    }
    if (known(c, 'huggins.complained')) {
      return [
        '“Ah. Valued guest.” Mr. Huggins’s smile is fixed, but his optical sensor gives a small, wounded twitch. “We have taken your feedback very seriously. We have put it in a drawer, and we are looking at the drawer.”',
      ];
    }
    return [
      'A tall, courteous robot in a bellhop’s cap steps out of the ruins of a hotel. “Good evening! Welcome to the Grand Meridian! I am Mr. Huggins. Please forgive the inconvenience of there being no roof, floors, or guests.”',
    ];
  }
}
