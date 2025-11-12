/// Hardware abstraction client for SmartPOS device bridge
library device_bridge_client;

// Main client
export 'src/client.dart';
export 'src/config.dart';
export 'src/exceptions.dart';

// Services
export 'src/services/printer_service.dart';
export 'src/services/scanner_service.dart';
export 'src/services/payment_terminal_service.dart';
export 'src/services/rfid_reader_service.dart';
export 'src/services/badge_printer_service.dart';
export 'src/services/access_control_service.dart';

// Models
export 'src/models/common_models.dart';
export 'src/models/printer_models.dart';
export 'src/models/scanner_models.dart';
export 'src/models/payment_models.dart';
export 'src/models/rfid_models.dart';
export 'src/models/badge_printer_models.dart';
export 'src/models/access_control_models.dart';

// Widgets (optional UI components)
export 'src/widgets/scanner_listener.dart';
export 'src/widgets/device_status_widget.dart';
export 'src/widgets/rfid_reader_widget.dart';
export 'src/widgets/access_control_widget.dart';
