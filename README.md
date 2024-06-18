<p align="center">
  <img src="https://iili.io/Jp44sJ1.png" height="100">
</p>

![Flutter Build](https://github.com/thermitex/cuckoo-flutter/actions/workflows/flutter-build.yml/badge.svg)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

Cuckoo is a mobile [Moodle](https://moodle.org) client majorly designed for [HKU Moodle](https://moodle.hku.hk). Written in Flutter, Cuckoo has a better performance compared with the official Moodle app and integrates useful features such as customizable reminder rules and workload estimation. Cuckoo can be easily modified to support **other** Moodle platforms as well.

## Highlighted Features

### Authentication

Cuckoo uses the same authentication mechanism as the official Moodle app to ensure safety of your personal information, and robustness against future Moodle website updates. Cuckoo communicates with Moodle through its dedicated web service APIs, which are encapsulated and easily accessible through the Moodle service module provided in Cuckoo's codebase.

### Completion Status Synchronization

Cuckoo is now able to sync with Moodle to check if the deadlines are marked as completed on the website, and then cross them out in the events list correspondingly. When a submission has been made for a course module, Cuckoo can automatically detect the change and reflect the status update in the app.

### Redesigned Reminders

Cuckoo allows one-time reminder creation for all current and future deadlines, without having to manually create one for each new event fetched. Cuckoo also features a straightforward interface to create a combination of reminder rules, specifying which types of the events the reminder should apply to.

### Custom Events

Apart from events fetched from Moodle (which are created by the owners of a course), users can also create their own custom events in Cuckoo, which are stored locally on device. These events can be associated with an existing course that the user has enrolled in, so that they can be easily managed together with the corresponding course.

### Direct Access to Moodle Resources

Cuckoo can obtain the list of currently enrolled courses as well as the contents of the coures modules. Therefore, Cuckoo can help download the files on Moodle directly from the device, without visiting the website or going through another round of authentication.

## Getting Started

1. Install the Flutter environment according to the [official guidance](https://docs.flutter.dev/get-started/install).

2. Verify the installation of Flutter by running:
```
flutter doctor
```

3. Clone the repository.

4. Get all dependencies by running in your working directory:
```
flutter pub get
```

5. Choose your device on the IDE of your choice and run:
```
flutter run
```

## UI Design

Cuckoo features a flat, rounded-corner design style that is largely inspired by [iOS design guidelines](https://developer.apple.com/design/human-interface-guidelines). You can also check the [Figma file](https://www.figma.com/design/GNgeV2TFlCc4Xn3iVQZ3xl/Cuckoo?node-id=0-1&t=JB3Psiyyg8HDkJqR-1) (although it's a bit rough).

For contributors, you are highly suggested to follow the same design style in your UI-related features/extensions.

## Contributing

Please let me know if you encounter a bug or have any suggestions by [filing an issue](https://github.com/thermitex/cuckoo-flutter/issues), or post it in [Discord community](https://cuckoo-hku.xyz/discord).

All contributions are welcome from bug fixes to new features and extensions. I would expect all contributions discussed in the issue tracker and going through PRs. Currently PR has two status checks:

- Code formatting check
- Build check

Please also let me know if you would like to be a maintainer of the repo.

Support Cuckoo's development and help Cuckoo stay on app stores:

<a href="https://www.buymeacoffee.com/jerryli" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

## License

Cuckoo uses MIT License.