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
  Contains `theme_provider.dart`. Manages global application state (Dark Mode / Light Mode) reactively using `ChangeNotifier` and `notifyListeners()`.
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
