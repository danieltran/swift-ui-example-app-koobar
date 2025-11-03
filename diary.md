# Task 1 - iPad Support
The `NavigationView` in `OnboardView` is replaced with a `NavigationStack`. As part of this change, I bumped the minimum deployment target to iOS 16.6 so that `NavigationStack` is available and to avoid using the deprecated `navigationViewStyle` modifier. I have done this for simplicity and typically on iOS we can stay fairly up to date with the latest versions as most of the userbase tends to migrate to newer versions of iOS fairly quickly. On projects where we do want to support a larger number of iOS versions to maximise the reach, then we could continue to use the `navigationViewStyle` modifier and keep the deployment target as it was originally.

I have added two `SpacerView`s to push the Sign In and Sign Up buttons to the bottom of the screen to make it easier for users to access the functionality on iPad.

I have left the code changes to just these changes to meet the requirements of this task, but in a real task when adding iPad support there would be a number of questions that I would be asking the designer, or product manager including:
- What is the overall approach for iPad support in this app? i.e. is it purely a replica of the iPhone experience, or is the intention to have a properly designed iPad optimised interface across the whole app, or maybe just specific screens?
- Are there already UI designs for the iPad that could be shared?
- Which other screens in the app will need to be updated? Adding iPad support is rarely a one screen change, but impacts the entire app.

Additionally there is alot of wasted space in the iPad design and so ideally the layout could better use the extra space by potentially allowing the logo image to take up more space or using a column based layout in landscape orientation with the Sign In and Sign Up buttons vertically stacked.

# Task 3 - Navigation
For the purpose of this exercise, I'm making the same assumption as Task 1 in that we're going to just replicate the iPhone experience which uses a `NavigationStack`.

However, from a UI perspective it would make sense to have a more iPad tailored UI experience here, potentially using multiple columns using NavigationSplitView or Sheets to be better take advantage of the extra screen space, particularly in landscape orientation.

I started off with a simple boolean flag based implementation (`showDropOffSelection`) in `NewRideView` and this works, but this approach works well for very simple scenarios - once there are multiple steps / routes it doesn't scale very well so the approach I've settled on is to update `NewRideView` to use a `NavigationPath`, and define a `NewRideRoute` enum for defining the routes across the NewRide allowing for type safe routes. I've taken this approach because it is a simple solution which fits with the overall complexity of the project but sets the foundation to be easily expanded later on as the app scales.

This approach can be expanded to support things like:
- Analytics events for routes, with benefits of type safety and exhaustiveness checking.
- Deep linking support with type safe parsing.
- State persistence to allow resuming from flows, such as dropping off in the middle of a onboarding flow and being able to preload previously entered user data.
So it's an approach which is flexible and can grow accommodate requirements in more mature apps without needing significant refactoring.

Additionally, the code to handle the routes could be split out into a `Router` to better separate navigation logic from the View layer. 
If the app had requirements for app wide deep linking and/or complex flows which involve moving between different parts of the app, then it might also be worthwhile to consider having a global router, instead of just within the NewRide section, e.g. using an `AppRouter` object which handles coordinating routing, analytics, deep linking and state persistence across the app. 