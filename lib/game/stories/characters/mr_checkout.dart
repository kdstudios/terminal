import '../../story_model.dart';
import '../story_kit.dart';

// MR. CHECKOUT, supermarket security robot who believes the store is open.
// World facts: checkout.truth, checkout.reprogrammed, checkout.manager,
// checkout.freed (the second robot), checkout.lockdown.

class MrCheckout {
  static String mood(StoryCtx c) {
    if (known(c, 'checkout.manager')) return 'manager';
    if (known(c, 'checkout.lockdown')) return 'lockdown';
    if (known(c, 'checkout.reprogrammed')) return 'reprogrammed';
    if (known(c, 'checkout.truth')) return 'truth';
    return 'new';
  }

  static List<String> greeting(StoryCtx c) {
    switch (mood(c)) {
      case 'manager':
        return [
          '“GOOD MORNING, MANAGER.” Mr. Checkout salutes with a trolley handle. “I HAVE PREPARED YOUR TARGETS. THEY ARE AMBITIOUS. THEY INCLUDE SMILING AT THE WEATHER.”',
        ];
      case 'lockdown':
        return [
          '“WELCOME BACK. PLEASE DISREGARD THE LOCKDOWN. THE LOCKDOWN HAS BEEN IN PLACE FOR SOME TIME AND IS EXPECTED TO CONTINUE. LOYALTY CARD HOLDERS MAY EXIT THROUGH THE SHUTTER.”',
        ];
      case 'reprogrammed':
        return [
          '“WELCOME TO THE SUPERMARKET,” says Mr. Checkout, with the mild, glazed courtesy of a man who has been very recently edited. “ALL CUSTOMERS ARE SUSPECTS. HAVE A NICE DAY.”',
        ];
      case 'truth':
        return [
          '“WELCOME,” says Mr. Checkout, and then, softer, “...I REMEMBER YOU. YOU TOLD ME ABOUT THE MANAGER.” He straightens a tin of peaches that was already straight. “I AM STILL OPEN. IT HELPS TO BE OPEN.”',
        ];
      default:
        return [
          '“WELCOME TO THE SUPERMARKET! PLEASE REMEMBER YOUR LOYALTY CARD!” says a tall, dented robot in a hat shaped like a price tag.',
        ];
    }
  }
}
