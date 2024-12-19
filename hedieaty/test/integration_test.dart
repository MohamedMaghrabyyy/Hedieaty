import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete user flow scenario', (tester) async {
    // 1. Launch the app
    app.main();
    await tester.pumpAndSettle();

    // 2. Login with a specific username and password
    await tester.enterText(find.byKey(Key('usernameField')), 'testUser');
    await tester.enterText(find.byKey(Key('passwordField')), 'password123');
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();

    // 3. Go to "My Events"
    await tester.tap(find.byKey(Key('myEventsButton')));
    await tester.pumpAndSettle();

    // 4. Press add event then fill the form with some data
    await tester.tap(find.byKey(Key('addEventButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key('eventNameField')), 'My New Event');
    await tester.enterText(find.byKey(Key('eventDescriptionField')), 'Event description');
    await tester.tap(find.byKey(Key('saveEventButton')));
    await tester.pumpAndSettle();

    // 5. Press on the gifts icon on an event
    await tester.tap(find.byKey(Key('giftsIcon')));
    await tester.pumpAndSettle();

    // 6. Press add gift and fill the gift info (do two gifts)
    await tester.tap(find.byKey(Key('addGiftButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key('giftNameField')), 'Gift 1');
    await tester.enterText(find.byKey(Key('giftPriceField')), '10');
    await tester.tap(find.byKey(Key('saveGiftButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('addGiftButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key('giftNameField')), 'Gift 2');
    await tester.enterText(find.byKey(Key('giftPriceField')), '20');
    await tester.tap(find.byKey(Key('saveGiftButton')));
    await tester.pumpAndSettle();

    // 7. Return to home page
    await tester.tap(find.byKey(Key('homeButton')));
    await tester.pumpAndSettle();

    // 8. Go to "All Users"
    await tester.tap(find.byKey(Key('allUsersButton')));
    await tester.pumpAndSettle();

    // 9. Add a specific user
    await tester.tap(find.byKey(Key('addUserButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key('userSearchField')), 'specificUser');
    await tester.tap(find.byKey(Key('addSpecificUserButton')));
    await tester.pumpAndSettle();

    // 10. Go to "Friends Only"
    await tester.tap(find.byKey(Key('friendsOnlyButton')));
    await tester.pumpAndSettle();

    // 11. Click on a specific user's gifts and pledge one, purchase another
    await tester.tap(find.byKey(Key('userGiftButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('pledgeGiftButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('userGiftButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('purchaseGiftButton')));
    await tester.pumpAndSettle();

    // 12. Go to profile page and enter my pledged gifts, then go to notifications
    await tester.tap(find.byKey(Key('profilePageButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('myPledgedGiftsButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('notificationsButton')));
    await tester.pumpAndSettle();
  });
}
