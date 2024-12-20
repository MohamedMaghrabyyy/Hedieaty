import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty/main.dart'; // Import the app entry point directly
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-End Test: Login, Search, and Navigate to Gifts', (WidgetTester tester) async {
    // Ensure Firebase is initialized before the test starts
    await Firebase.initializeApp();

    // Launch the app
    await tester.pumpWidget(MyApp());

    // Wait for any animations or setup to complete
    await tester.pumpAndSettle();

    // Log in
    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('loginButton'));

    // Ensure the login fields are present
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    // Enter the credentials
    await tester.enterText(emailField, 'mohamed_elmaghrabyyy@mail.com');
    await tester.pump(const Duration(seconds: 1)); // Wait for the field to update
    await tester.enterText(passwordField, 'test1234');
    await tester.pump(const Duration(seconds: 1)); // Wait for the field to update

    // Tap the login button
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Open Events Page
    final eventsButton = find.byKey(const Key('myEventsButton'));
    expect(eventsButton, findsOneWidget);
    await tester.tap(eventsButton);
    await tester.pumpAndSettle();

    // Add Two Events
    final addEventButton = find.byKey(const Key('addEvent'));
    expect(addEventButton, findsOneWidget);

    // Add the first event
    await tester.tap(addEventButton);
    await tester.pumpAndSettle();

    // Fill out the first event form
    final eventNameField = find.byKey(const Key('event_name_field'));
    final eventDescriptionField = find.byKey(const Key('event_description_field'));
    final eventLocationField = find.byKey(const Key('event_location_field'));
    final eventDatePicker = find.byKey(const Key('event_date_picker'));
    final eventSaveButton = find.byKey(const Key('create_event_button'));

    // Enter details for the first event
    await tester.enterText(eventNameField, 'Birthday Party');
    await tester.pumpAndSettle();  // Delay for the text field update
    await tester.enterText(eventDescriptionField, 'A fun birthday celebration.');
    await tester.pumpAndSettle();  // Delay for the text field update
    await tester.enterText(eventLocationField, 'Central Park');
    await tester.pumpAndSettle();  // Delay for the text field update
    await tester.tap(eventDatePicker); // Simulate selecting a date
    await tester.pumpAndSettle();  // Delay for the date picker to appear
    await tester.tap(find.text('OK')); // Assume 'OK' is the button in the date picker
    await tester.pumpAndSettle(Duration(seconds: 1)); // Delay after selecting the date

    // Save the event
    await tester.tap(eventSaveButton);
    await tester.pumpAndSettle();  // Delay for event save process

    // Add the second event
    await tester.tap(addEventButton);
    await tester.pumpAndSettle();  // Delay for the page transition

    // Fill out the second event form
    await tester.enterText(eventNameField, 'Wedding Celebration');
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update
    await tester.enterText(eventDescriptionField, 'A grand wedding event.');
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update
    await tester.enterText(eventLocationField, 'Downtown Hall');
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update
    await tester.tap(eventDatePicker); // Simulate selecting a date
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the date picker to appear
    await tester.tap(find.text('OK')); // Assume 'OK' is the button in the date picker
    await tester.pumpAndSettle(Duration(seconds: 1)); // Delay after selecting the date

    // Save the event
    await tester.tap(eventSaveButton);
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for event save process

    // Verify events are added dynamically
    final eventTile = find.byType(ListTile).first;  // Find the first ListTile, representing any event
    expect(eventTile, findsOneWidget);  // Ensure at least one event tile is found

    // Tap the gift icon of the first event
    final eventGiftIcon = find.byKey(const Key('event_gift_icon')).first;  // Find the first gift icon
    expect(eventGiftIcon, findsOneWidget);  // Ensure the gift icon exists

    await tester.tap(eventGiftIcon);  // Tap the gift icon to open the GiftListPage
    await tester.pumpAndSettle(Duration(seconds: 1));  // Wait for the navigation to complete

    // Add a gift for the first event
    final addGiftButton = find.byKey(const Key('addGiftButton'));
    expect(addGiftButton, findsOneWidget);
    await tester.tap(addGiftButton);
    await tester.pumpAndSettle(Duration(seconds: 1));

    // Fill out gift details including Category
    final giftNameField = find.byKey(const Key('gift_name_field'));
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update
    final giftDescriptionField = find.byKey(const Key('gift_description_field'));
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update
    final giftPriceField = find.byKey(const Key('gift_price_field'));
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update
    final giftCategoryField = find.byKey(const Key('gift_category_field')); // Replacing giftDateField with giftCategoryField
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update
    final giftSaveButton = find.byKey(const Key('save_gift_button'));

    // Enter gift details for the first event
    await tester.enterText(giftNameField, 'Toy Car');
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update
    await tester.enterText(giftDescriptionField, 'A cool toy car.');
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update
    await tester.enterText(giftPriceField, '20');
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update
    await tester.enterText(giftCategoryField, 'Toys'); // Enter the category for the gift
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update

    // Save the gift
    await tester.tap(giftSaveButton);
    await tester.pumpAndSettle(Duration(seconds: 1));


    // Go back to the events page using Navigator.pop()
    await tester.pageBack();
    await tester.pumpAndSettle(Duration(seconds: 1));

    // Tap the gift icon of the second event (select the second event)
    final eventGiftIcon2 = find.byKey(const Key('event_gift_icon')).at(1);  // Find the second gift icon
    expect(eventGiftIcon2, findsOneWidget);  // Ensure the gift icon exists

    await tester.tap(eventGiftIcon2);  // Tap the gift icon of the second event to open the GiftListPage
    await tester.pumpAndSettle(Duration(seconds: 1));  // Wait for the navigation to complete

    // Add a gift for the second event
    await tester.tap(find.byKey(const Key('addGiftButton')));  // Open gift adding page for the second event
    await tester.pumpAndSettle(Duration(seconds: 1));

// Fill out gift details for the second event
    await tester.enterText(find.byKey(const Key('gift_name_field')), 'Wedding Ring');
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update

    await tester.enterText(find.byKey(const Key('gift_description_field')), 'A beautiful wedding ring.');
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update

    await tester.enterText(find.byKey(const Key('gift_price_field')), '100');
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update

    await tester.enterText(find.byKey(const Key('gift_category_field')), 'Jewelry'); // Enter the category for the gift
    await tester.pumpAndSettle(Duration(seconds: 1));  // Delay for the text field update

    await tester.tap(find.byKey(const Key('save_gift_button')));
    await tester.pumpAndSettle();

    // Go back to the events page using Navigator.pop()
    await tester.pageBack();
    await tester.pumpAndSettle(Duration(seconds: 1));

    // Step 9: Go back to the events page using Navigator.pop()
    await tester.pageBack();
    await tester.pumpAndSettle(Duration(seconds: 1));

    // Open Events Page
    final giftsButton = find.byKey(const Key('myGiftsButton'));
    expect(eventsButton, findsOneWidget);
    await tester.tap(giftsButton);
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Go back to the events page using Navigator.pop()
    await tester.pageBack();
    await tester.pumpAndSettle(Duration(seconds: 1));

    // Tap on the "View All Users" button
    final viewAllUsersButton = find.byKey(const Key('toggleViewButton'));
    expect(viewAllUsersButton, findsOneWidget);
    await tester.tap(viewAllUsersButton);
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Wait for 3 seconds and tap the "View All Users" button again
    await tester.tap(viewAllUsersButton);
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Tap on the hamburger menu (three bars)
    final hamburgerMenu = find.byKey(const Key('profilePageButton'));
    expect(hamburgerMenu, findsOneWidget);
    await tester.tap(hamburgerMenu);
    await tester.pumpAndSettle(Duration(seconds: 2));

    // Open "Update Profile Information" for 2 seconds
    final updateProfileButton = find.byKey(const Key('updateProfileButton'));
    expect(updateProfileButton, findsOneWidget);
    await tester.tap(updateProfileButton);
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.pageBack();  // Back out from profile update
    await tester.pumpAndSettle();  // Ensure UI settles after going back

// Open "Notifications" for 2 seconds
    final notificationsButton = find.byKey(const Key('notificationsButton'));
    expect(notificationsButton, findsOneWidget);
    await tester.tap(notificationsButton);
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.pageBack();  // Back out from notifications
    await tester.pumpAndSettle();  // Ensure UI settles after going back

// Open "My Created Events" for 2 seconds
    final createdEventsButton = find.byKey(const Key('createdEventsButton'));
    expect(createdEventsButton, findsOneWidget);
    await tester.tap(createdEventsButton);
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.pageBack();  // Back out from created events
    await tester.pumpAndSettle();  // Ensure UI settles after going back

// Open "My Pledged Gifts" for 2 seconds
    final pledgedGiftsButton = find.byKey(const Key('pledgedGiftsButton'));
    expect(pledgedGiftsButton, findsOneWidget);
    await tester.tap(pledgedGiftsButton);
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.pageBack();  // Back out from pledged gifts
    await tester.pumpAndSettle();  // Ensure UI settles after going back

// Log out
    final logOutButton = find.byKey(const Key('logOutButton'));
    expect(logOutButton, findsOneWidget);
    await tester.tap(logOutButton);
    await tester.pumpAndSettle(Duration(seconds: 2));


  });
}
