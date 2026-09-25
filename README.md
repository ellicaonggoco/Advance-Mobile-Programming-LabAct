# Lab Activity 2: API & State Management

## Discussion

### How Model, Services, and Screen interact to render the API endpoint

1. **Model (`product_model.dart` / `product.dart`)**  
   The model defines the structure of the product data received from the API (e.g., id, title, price, category, rating, thumbnail). It parses the raw JSON response into Dart objects using `Product.fromJson` so that data can be easily accessed throughout the app with type safety.  
   *(Dito ina-convert yung raw JSON data na galing sa API para maging typed Dart objects para madaling gamitin sa buong app.)*

2. **Service (`product_service.dart`)**  
   The service contains the HTTP request logic. It performs an async GET request to the products API endpoint (`https://dummyjson.com/products`). Upon receiving a success response (HTTP status 200), it decodes the JSON payload into a list of `Product` models and handles potential network errors.  
   *(Ito yung nagha-handle ng HTTP GET request papunta sa dummyjson API para i-fetch yung listahan ng mga produkto.)*

3. **Screen (`product_screen.dart` & `product_detail_screen.dart`)**  
   The screen layer handles the user interface. `product_screen.dart` uses a `FutureBuilder` to trigger `getAllProducts()` from `ProductService`. It shows a progress indicator while waiting for data and renders the product grid once loaded. Clicking a product card navigates to `product_detail_screen.dart` to view full item details.  
   *(Ito yung UI layer. Gumagamit ng FutureBuilder para mag-antay sa API data bago ipakita sa grid cards. Kapag kini-click yung card, lilipat sa details screen.)*

### Discussion on the Design Pattern

This activity uses the **Service-Model-Provider** design pattern to separate concerns across the project:

- **Model**: Handles data structures and JSON deserialization.  
  *(Naka-focus lang dito yung data structure at pag-parse ng JSON.)*
- **Service**: Isolates network calls and API integration away from UI code.  
  *(Hiwalay ang API network calls para malinis ang UI files.)*
- **Provider (`theme_provider.dart`)**: Manages application-wide state (dark and light mode toggle) using `ChangeNotifier` and `notifyListeners()`.  
  *(Pinamamahalaan nito yung global theme state o dark/light mode switch sa buong app.)*
- **Screen / Widgets**: Handles layout rendering and user interactions.  
  *(Naka-focus lang sa pag-display ng UI at pag-respond sa user actions.)*

By separating API calls, state management, and UI layout into distinct folders and classes, the codebase becomes modular, easier to debug, and simple to maintain.  
*(Dahil hiwa-hiwalay ang responsibilidad ng bawat folder at file, mas madaling i-debug at i-maintain yung project.)*

---

# Lab Activity 3: API Part II & State Management

## Discussion

### 1. How Cart Model, Services, and Screen Interact to Render the API Endpoint and Navigate to the Same `detail_screen.dart`

1. **Model Layer (`models/cart.dart` & `models/product.dart`)**  
   - The `Cart` and `CartProduct` models define strongly-typed Dart objects matching the JSON schema from the `https://dummyjson.com/carts` endpoint.  
   - `Cart.fromJson` parses the top-level cart metadata (`id`, `total`, `discountedTotal`, `userId`, `totalProducts`, `totalQuantity`) and maps the nested `products` JSON array into a list of `CartProduct` instances using `CartProduct.fromJson`.  
   - When a user taps a cart item, the `CartProduct` data is mapped into a `Product` model instance so that `detail_screen.dart` can render the full product view seamlessly without duplicating screen widgets.  
   *(Ang Cart at CartProduct models ang nagko-convert ng raw JSON data mula sa /carts endpoint upang maging structured Dart objects. Kapag pinindot ang item sa cart, kino-convert ito sa Product model upang magamit muli ang iisang detail_screen.dart nang walang duplication.)*

2. **Service Layer (`services/cart_service.dart`)**  
   - The `CartService` encapsulates all HTTP networking operations related to the cart features:
     - `getAllCarts()`: Performs `GET https://dummyjson.com/carts` to retrieve all carts.
     - `getCartById(int cartId)`: Performs `GET https://dummyjson.com/carts/{id}` to fetch a specific cart record.
     - `getCartByUserId(int userId)`: Performs `GET https://dummyjson.com/carts/user/{userId}` to fetch the cart associated with a specific user account.
     - `addToCart(...)`: Performs `POST https://dummyjson.com/carts/add` to simulate adding product items to a user cart.  
   - Handles network errors and validates HTTP status codes (`200 OK` or `201 Created`).  
   *(Nasa CartService ang lahat ng logic para sa HTTP requests tulad ng pag-fetch ng cart ng user, pagkuha ng cart gamit ang ID, at pag-add to cart gamit ang POST method.)*

3. **Screen Layer (`screens/cart_screen.dart` & `screens/detail_screen.dart`)**  
   - `cart_screen.dart` uses a `FutureBuilder` to fetch and render the user's cart items from `CartService`. It displays a list of cart item cards featuring the product thumbnail, title, price, discount details, and interactive quantity counters (`+` / `-`).  
   - When any cart item card is clicked, `Navigator.push` opens `DetailScreen` (`detail_screen.dart`), passing the converted product details (**Enhancement 1**).  
   - `detail_screen.dart` also provides an interactive "Add to Cart" button that invokes `CartService().addToCart(...)` with real-time SnackBar confirmation (**Enhancement 3**).  
   *(Ang CartScreen ang nagpapakita ng UI ng cart at mga items nito. Bawat cart item ay napipindot patungo sa DetailScreen kung saan makikita ang buong detalye ng produkto at pwede rin itong i-add to cart.)*

---

### 2. Discussion on the Updated Design Pattern in this Activity

In this activity, the **Service-Model-Provider** architectural design pattern is expanded to support multiple distinct resources (`Products` and `Carts`) while keeping the codebase decoupled, maintainable, and scalable:

- **Models (`/models`)**:  
  Contains `cart.dart` and `product.dart`. Responsible strictly for data structures, serialization (`toJson`), and deserialization (`fromJson`).
- **Services (`/services`)**:  
  Contains `cart_service.dart` and `product_service.dart`. Isolates remote API communications, URL parameters, headers, and error handling away from widget code.
- **Providers (`/providers`)**:  
  Contains `theme_provider.dart` and `cart_provider.dart`. Manages global application state (Dark Mode / Light Mode and Cart state reactivity across Home and Cart screens) reactively using `ChangeNotifier` and `notifyListeners()`.
- **Screens (`/screens`)**:  
  Contains `home_screen.dart`, `product_screen.dart`, `cart_screen.dart`, `detail_screen.dart`, and `settings_screen.dart`. Focuses on presentation, user interactions, and view navigation.
- **Widgets (`/widgets`)**:  
  Contains shared reusable widgets like `custom_text.dart` to enforce typography and styling consistency throughout the application.

#### Benefits of the Design Pattern:
1. **Separation of Concerns (SoC)**: Business logic, API calls, and presentation layers are isolated.
2. **Component Reusability**: `detail_screen.dart` is reused by both `product_screen.dart` and `cart_screen.dart`.
3. **Maintainability & Testability**: Services and models can be unit-tested independently without rendering Flutter UI components.

---

### 3. Discussion on How to Use `getbyId` at the Cart Endpoint

The DummyJSON API provides specialized endpoints to query cart data by specific identifiers:

1. **Get Cart by Cart ID (`/carts/{id}`)**:
   - **Endpoint**: `GET https://dummyjson.com/carts/{id}` (e.g., `GET https://dummyjson.com/carts/1`)
   - **Usage**: Used when the unique cart ID is already known.
   - **Response**: Returns a single Cart JSON object with details including `id`, `products` list, `total`, `discountedTotal`, `userId`, `totalProducts`, and `totalQuantity`.
   ```dart
   Future<Cart> getCartById(int cartId) async {
     final response = await http.get(Uri.parse('$host/carts/$cartId'));
     if (response.statusCode == 200) {
       final Map<String, dynamic> data = jsonDecode(response.body);
       return Cart.fromJson(data);
     } else {
       throw Exception('Failed to load cart with id: $cartId');
     }
   }
   ```

2. **Get Cart by User ID (`/carts/user/{userId}`)**:
   - **Endpoint**: `GET https://dummyjson.com/carts/user/{userId}` (e.g., `GET https://dummyjson.com/carts/user/5`)
   - **Usage**: Used to fetch the specific shopping cart belonging to the currently logged-in user account (**Enhancement 3**).
   - **Response**: Returns a JSON object containing a `carts` array of carts associated with that user ID.
   ```dart
   Future<Cart> getCartByUserId(int userId) async {
     final response = await http.get(Uri.parse('$host/carts/user/$userId'));
     if (response.statusCode == 200) {
       final Map<String, dynamic> data = jsonDecode(response.body);
       final List cartsJson = data['carts'] ?? [];
       if (cartsJson.isNotEmpty) {
         return Cart.fromJson(cartsJson.first);
       }
       throw Exception('No cart found for user: $userId');
     } else {
       throw Exception('Failed to load cart for user: $userId');
     }
   }
   ```

3. **Add to Cart (`/carts/add`)**:
   - **Endpoint**: `POST https://dummyjson.com/carts/add`
   - **Headers**: `{'Content-Type': 'application/json'}`
   - **Body**:
     ```json
     {
       "userId": 1,
       "products": [
         {
           "id": 1,
           "quantity": 1
         }
       ]
     }
     ```
   - **Usage**: Passes the selected product ID and quantity to create/update cart items dynamically.

---

### Enhancements Implemented Summary:
- **Enhancement 1**: Built `cart_screen.dart` rendering the `/carts` API endpoint, where each cart item is clickable and navigates to the shared `detail_screen.dart`.
- **Enhancement 2**: Implemented Chat as a `FloatingActionButton` on `home_screen.dart`, which is dynamically hidden when viewing the `cart_screen` tab.
- **Enhancement 3**: Integrated single-user cart querying via `getCartByUserId` and implemented the "Add to Cart" functionality via `POST /carts/add` on `detail_screen.dart`.

---

# Lab Activity 4: API Part III & Persistent Authentication

## Discussion

### 1. How User Model, Services, and Screen Interact to Render the API Endpoint Going to `profile_screen.dart`

1. **Model Layer (`models/user.dart`)**  
   - The `User` model encapsulates user profile information returned from the authentication endpoint (`https://dummyjson.com/auth/login`) and local session storage.  
   - It defines strong typing for all essential attributes: `id`, `username`, `email`, `firstName`, `lastName`, `gender`, `image`, `accessToken`, and `refreshToken`.  
   - `User.fromJson(Map<String, dynamic> json)` dynamically deserializes both the API authentication payload and the cached `SharedPreferences` dictionary, guaranteeing type-safe access across the application.  
   *(Ang `User` model ang nagko-convert at nag-iistruktura sa raw data na galing sa API login endpoint at sa local storage upang maging type-safe Dart object na magagamit sa buong application tulad ng pagpapakita ng profile details.)*

2. **Service Layer (`services/user_service.dart`)**  
   - `loginUser(String username, String password)`: Sends a `POST` request to `$host/auth/login` containing user credentials. Upon receiving HTTP 200, it parses the JSON response and immediately caches the credentials and profile attributes via `saveUserData(data)`.  
   - `saveUserData(Map<String, dynamic> userData)`: Serializes user attributes (`id`, `username`, `email`, `firstName`, `lastName`, `gender`, `image`, `accessToken`, `refreshToken`, `token`) into disk-persistent local storage using `SharedPreferences`.  
   - `getUserData()` & `getUser()`: Asynchronously reads the stored user attributes from `SharedPreferences` and re-constructs the strongly-typed `User` model without needing another remote network round-trip.  
   - `isLoggedIn()`: Validates whether a non-empty `accessToken` or `token` exists in persistent storage.  
   - `logout()`: Clears the persistent session data via `prefs.clear()`.  
   *(Nasa `UserService` ang networking logic para sa authentication at ang pag-persist ng session data gamit ang `SharedPreferences`. Dito iniimbak ang token at profile ng user sa storage upang manatiling naka-login kahit i-restart ang app, at dito rin kinukuha ang cached data para i-render ang profile screen nang mabilis.)*

3. **Screen Layer (`screens/splash_screen.dart`, `screens/signin_screen.dart`, and `screens/profile_screen.dart`)**  
   - **`splash_screen.dart`**: Acts as the gatekeeper upon application launch. Its `_checkAuthentication()` method awaits 1500ms and queries `_userService.isLoggedIn()`. If authenticated, it navigates directly to `/home` with the cached user payload; otherwise, it directs the user to `/signin`.  
   - **`signin_screen.dart`**: Formulates the credentials input form, validates inputs, and triggers `_login()`, handling loading spinners and error feedback via `SnackBar`.  
   - **`profile_screen.dart`**: Consumes the `User` model (either from navigation arguments or `_userService.getUser()`) to render the user's avatar, full name, `@username`, and information cards for `Email`, `Gender`, and `User ID`. It also provides the "Log Out" action that invokes `_userService.logout()` and resets navigation back to `/signin`.  
   *(Ang UI layer ang nagpapakita ng visual flow: chine-check ng splash screen kung may valid session, pinapapasok ang user sa sign-in screen kapag wala, at ipinapakita ang buong detalye ng user sa profile screen gamit ang data mula sa User model.)*

---

### 2. Discussion on the Updated Design Pattern in this Activity

In this activity, the **Service-Model-Provider** architectural pattern is upgraded to incorporate **Persistent Local State & Session Management**:

- **Model Layer (`/models`)**:  
  Houses domain models (`user.dart`, `cart.dart`, `product.dart`). Implements JSON serialization/deserialization for clean boundary conversions.
- **Service Layer (`/services`)**:  
  Houses remote networking and persistence logic (`user_service.dart`, `cart_service.dart`, `product_service.dart`). Manages RESTful HTTP communication, endpoint headers, error throwing, and direct interaction with the device's native key-value storage via `SharedPreferences`.
- **Provider Layer (`/providers`)**:  
  Manages reactive in-memory application state (`cart_provider.dart` and `theme_provider.dart`). Providers listen to changes and broadcast state updates reactively across widgets.
- **Screen Layer (`/screens`)**:  
  Comprises `splash_screen.dart`, `signin_screen.dart`, `home_screen.dart`, `product_screen.dart`, `cart_screen.dart`, `detail_screen.dart`, `profile_screen.dart`, and `settings_screen.dart`. Screens observe providers and consume services to present UI layouts adhering strictly to user interaction states.
- **Widget Layer (`/widgets`)**:  
  Provides standardized reusable design elements (such as `custom_text.dart`) to ensure consistent typography and design system compliance.

#### Architectural Advantages:
1. **Session Continuity**: Local persistence decouples user authentication state from ephemeral memory, giving users persistent access across app restarts.
2. **Decoupled Responsibilities**: Screens never interact directly with raw HTTP or low-level preference APIs; all transactions are routed through models and services.
3. **Data Integrity & Robustness**: Null-safe parsing in models guarantees that missing backend attributes do not cause application-wide runtime crashes.

---

### 3. Discussion on How to Use the Saved Data in Rendering the `cart_screen.dart` by User ID

1. **Retrieving the Active User ID**:  
   Upon successful login or during the initialization of `home_screen.dart`, the user's details are retrieved from `SharedPreferences` through `UserService().getUserData()` (or `UserService().getUser()`). This yields the logged-in user's numeric `id` (e.g., `userId = 1` for Emily Johnson).
   ```dart
   final userData = await _userService.getUserData();
   final int userId = userData['id'] ?? 1;
   ```

2. **Passing `userId` to `CartProvider`**:  
   Rather than hardcoding a static cart identifier, `CartProvider.loadCart([int? userId])` dynamically scopes the cart query to the authenticated account:
   ```dart
   Future<void> loadCart([int? userId]) async {
     int targetUserId = userId ?? _currentUserId;
     if (userId == null) {
       final userData = await _userService.getUserData();
       final savedId = userData['id'] as int? ?? 0;
       if (savedId > 0) targetUserId = savedId;
     }
     _currentUserId = targetUserId;
     _cart = await _cartService.getCartByUserId(_currentUserId);
     notifyListeners();
   }
   ```

3. **Querying the User Cart Endpoint**:  
   `CartService.getCartByUserId(userId)` queries `https://dummyjson.com/carts/user/{userId}`:
   ```dart
   Future<Cart> getCartByUserId(int userId) async {
     final response = await http.get(Uri.parse('$host/carts/user/$userId'));
     if (response.statusCode == 200) {
       final Map<String, dynamic> data = jsonDecode(response.body);
       final List cartsJson = data['carts'] ?? [];
       if (cartsJson.isNotEmpty) {
         return Cart.fromJson(cartsJson.first);
       }
       throw Exception('No cart found for user ID: $userId');
     }
     throw Exception('Failed to load cart for user ID: $userId');
   }
   ```

4. **Dynamic Cart Rendering**:  
   `CartScreen` observes `CartProvider` using `context.watch<CartProvider>()`. When `loadCart(userId)` finishes, `notifyListeners()` triggers an automatic rebuild of the cart UI, instantly displaying the specific items, quantities, and subtotal belonging to that authenticated user.

---

### Enhancements Implemented Summary:
- **Enhancement 1**: Designed and implemented custom UI for `splash_screen.dart` displaying National University / NUBD Exchange branding, incorporating `_checkAuthentication()` for seamless persistent session navigation.
- **Enhancement 2**: Built branded UI for `signin_screen.dart` with username/password validation, `_login()` authentication handling, SnackBar notifications, and demo credentials assistance.
- **Enhancement 3**: Created `models/user.dart` and implemented `profile_screen.dart` showcasing avatar, name, handle, email, gender, user ID, and a functional log out routine. Configured `CartProvider` and `HomeScreen` to dynamically fetch and render the user's specific cart by `userId`.

---

# Lab Activity 5: Firebase Authentication & Account Management

## Discussion

### 1. Workflow for DummyJSON vs Firebase Implementation (From signIn to signUp)

#### A. DummyJSON Workflow
1. **Sign-In (`/signin`)**:
   - The user inputs their `username` (e.g., `emilys`) and `password` (e.g., `emilyspass`).
   - The app sends an HTTP `POST` request to `https://dummyjson.com/auth/login` with `{'Content-Type': 'application/json'}` and body containing `username` and `password`.
   - DummyJSON validates the static test credentials and responds with HTTP `200 OK` containing a mock JWT `accessToken`, `refreshToken`, and user attributes (e.g., id, firstName, lastName, email, gender, image).
   - `UserService.saveUserData()` writes these credentials into local persistent storage using `SharedPreferences`, and sets `loginType` to `'dummyjson'`.
   - The user is redirected to `/home`, and the cart is dynamically fetched using the numeric `userId`.
2. **Sign-Up (`/signup`)**:
   - DummyJSON is a simulated mock REST API without a stateful database or persistent backend user store. Registering a user against DummyJSON via `POST /users/add` only mirrors back a mock object without actually creating an active authentication entry or verifying credentials for subsequent logins.  
   *(Sa DummyJSON, simulated lamang ang backend. Kapag nag-login, nagpapadala ng HTTP POST sa dummyjson API at nagbabalik ng fake JWT token. Walang totoong persistent user registration dahil mock server lamang ito.)*

#### B. Firebase Authentication Workflow
1. **Sign-Up (`/signup`)**:
   - The user navigates to `SignupScreen` featuring 7 required input fields:
     - `fName` (First Name)
     - `lName` (Last Name)
     - `age` (Age, numeric validation)
     - `contactNo` (Contact Number, phone format)
     - `username` (Username, minimum 3 characters)
     - `emailAddress` (Email, RFC regex format validation)
     - `password` (Password, minimum 6 characters with confirmation check)
   - When the user taps **Register Account**, `_handleSignUp()` validates all form fields and triggers:
     ```dart
     await userService.value.createAccount(
       email: email,
       password: password,
       displayName: fullName,
     );
     ```
   - This invokes `FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)` under the hood. Firebase securely provisions a new account in the cloud, creates a unique `UID`, hashes the password with secure cryptographic algorithms, and applies the user's `displayName`.
   - A success SnackBar confirms registration, and the app routes the user to `SigninScreen`.
2. **Sign-In (`/signin`)**:
   - The user toggles to the **Firebase Auth** tab and provides their registered `email` and `password`.
   - Tapping **Log In** invokes:
     ```dart
     await userService.value.signIn(
       email: email,
       password: password,
     );
     ```
   - Firebase securely authenticates the user credentials, manages automatic token refresh cycles, and exposes the authenticated user through `FirebaseAuth.instance.currentUser`.
   - `UserService.signIn()` sets `loginType` to `'firebase'` and synchronizes account details to `SharedPreferences` for fast startup retrieval.
   - The user is navigated to `/home`.  
   *(Sa Firebase Authentication, mayroon tayong totoong cloud backend sa Google. Sa registration, nire-record agad ang bagong account gamit ang createUserWithEmailAndPassword. Pag nag-login naman gamit ang signInWithEmailAndPassword, pinapatunayan ng Firebase ang credentials at nagbibigay ng secure token na awtomatikong nagre-refresh.)*

---

### 2. Main Idea for the `UserService` Implementation

The main architectural idea of the `UserService` is to serve as an **Abstraction and Facade Pattern** for user management and authentication:

1. **Centralized Facade & Separation of Concerns**:
   - The UI screens (`signin_screen.dart`, `signup_screen.dart`, `profile_screen.dart`, `settings_screen.dart`, and `splash_screen.dart`) never contain direct backend networking or low-level SDK implementation details.
   - All authentication actions—whether communicating with a REST API via `http.post` or with Google's Cloud Authentication service via `FirebaseAuth`—are encapsulated cleanly inside `UserService`.

2. **Reactive Single Source of Truth**:
   - Instantiated as a global `ValueNotifier<UserService> userService = ValueNotifier(UserService())`, allowing the entire widget tree to reactively listen or call authentication methods directly:
     - `signIn({required String email, required String password})`
     - `createAccount({required String email, required String password, String? displayName})`
     - `signOut()`
     - `updateUsername({required String username})`
     - `deleteAccount({required String email, required String password})`
     - `resetPasswordFromCurrentPassword({required String currentPassword, required String newPassword, required String email})`
     - `getUserData()` and `getUser()`
     - `isLoggedIn()`
     - `logout()`

3. **Hybrid Authentication Management**:
   - `UserService` seamlessly differentiates between DummyJSON users and Firebase authenticated users via `getLoginType()` and `setLoginType(type)`.
   - When `getUserData()` is called, it inspects `loginType`:
     - If `'firebase'`, it extracts live data from `FirebaseAuth.instance.currentUser` (such as `email`, `displayName`, and `uid`).
     - If `'dummyjson'`, it extracts the stored JSON attributes from `SharedPreferences`.
   - This ensures the UI remains completely agnostic of the underlying auth provider.  
   *(Ang pangunahing ideya ng UserService ay maging iisang sentro o controller para sa lahat ng authentication logic. Hindi kailangang malaman ng UI kung paano nagwo-work ang Firebase o REST API; tumatawag lang ito sa UserService methods tulad ng signIn(), createAccount(), at updateUsername().)*

---

### 3. Benefits of the Firebase Implementation on the Current Laboratory (Flutter Application)

1. **Production-Grade Security & Encryption**:
   - Firebase Authentication handles end-to-end credential security, zero-plaintext storage, salted hashing, and rate-limiting against brute force attacks out of the box, which mock APIs cannot provide.
2. **Automatic Token Lifecycle Management**:
   - Unlike basic REST endpoints where expired JWT tokens require manual refresh interceptors, the Firebase SDK automatically refreshes user ID tokens silently in the background.
3. **Reactive Real-Time Auth State**:
   - Firebase exposes the `authStateChanges()` stream, allowing Flutter apps to react immediately to auth events (login, logout, session expiration, token revocation) anywhere in the application.
4. **Native Self-Service Account Management**:
   - Allows users to directly update their profile (`updateDisplayName`), securely update their password (`updatePassword` with reauthentication), and permanently delete their account (`delete()`) through secure cloud APIs without needing to write custom backend endpoints.
5. **Cross-Platform Scalability**:
   - By configuring Firebase via FlutterFire CLI (`lib/firebase_options.dart`), the Flutter application supports Android, iOS, and Web with native SDK bindings, laying the foundation for additional Firebase cloud services such as Cloud Firestore, Cloud Storage, and Push Notifications.  
   *(Napakalaking tulong ng Firebase dahil tunay itong cloud backend na may matibay na security, automatic token refresh, real-time auth streams, at mga built-in functions para sa pag-update ng username, pagpapalit ng password, at pag-delete ng account nang hindi na kailangan gumawa ng sariling server.)*

---

### Enhancements Implemented Summary:
- **Enhancement 1: UserService Functions**:
  - Implemented `signIn`, `createAccount`, `signOut`, `updateUsername`, `deleteAccount`, and `resetPasswordFromCurrentPassword` using `FirebaseAuth.instance`.
  - Added session cleanup on `logout()` and `deleteAccount()`.
- **Enhancement 2: Dummy JSON vs Firebase Auth**:
  - Created `screens/signup_screen.dart` featuring 7 required fields: `fName`, `lName`, `age`, `contactNo`, `username`, `emailAddress`, and `password` (with validation and confirmation).
  - Updated `screens/signin_screen.dart` with a dual-mode toggle for DummyJSON and Firebase Auth, password visibility toggles, and seamless navigation to Sign Up.
  - Registered `/signup` route in `lib/main.dart`.
- **Enhancement 3: Profile Screen & Settings**:
  - Updated `screens/profile_screen.dart` to fetch data via `UserService().getUserData()` and display contextual information based on `LoginType()`.
  - Added dialogs in `ProfileScreen` for Firebase users to **Update Username**, **Change Password**, and **Delete Account**.
  - Integrated a functional **Log Out** button in `screens/settings_screen.dart` that clears stored sessions and returns to `/signin`.


