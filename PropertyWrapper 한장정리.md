## PropertyWrapper란
```swift
PropertyWrapper는 프로퍼티의 저장방식이나 읽고 쓰는 방법을 캡슐화하는것을 말한다.
이는 코드의 재사용성을 높이고, 보일러플레이트 코드를 줄이는데 도움을 준다.
추가적인 로직을 부여하는 코드를 부여하는 포장지 라고 생각하면 된다.

내가 어떤 String변수에 띄어쓰기를 없애고 싶은데
이걸 계속 아주 자주 많이 사용할것 같다면
항상 이런 띄어쓰기를 제거하는 코드를 만드는것은 번거롭고 많은 코드의 작성을 유도할것이다.
만약 이때 PropertyWrapper를 사용하면 이러한 번거로움을 줄일수 있게된다.

// 커스텀 propertyWrapper를 정의
@propertyWrapper
struct NotSpaceStringWrapper {
    private var value: String = ""

    var wrappedValue: String {
        get { value }
        set { value = newValue.replacingOccurrences(of: " ", with: "") }
    }
}

struct Example {
    // 변수에 프로퍼티 래퍼 선언
    @NotSpaceStringWrapper var word: String
}

var example = Example()
example.word = "가 나 다 라 마 바 사"

// 결과
print(example.word)
```

## SwiftUI PropertyWrapper
여러 SwiftUI에서 제공하는 PropertyWrapper들이 있다.     
천천히 하나씩 알아보도록 하자.     

### 1. @State (변수의 상태변화 관찰)
```swift
SwiftUI에서 상태를 선언하고 관리하는데 사용하는 ProeprtyWrapper이다.
이걸 사용하면 SwiftUI의 여러 뷰들이 상태를 내부적으로 추적하고 상태가 변경될때 자동으로 UI를 업데이트한다.

struct ContentView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
                .font(.largeTitle)

            Button(action: {
                count += 1
            }) {
                Text("Increment")
            }
        }
    }
}
```

### 2. @Binding (자식뷰와 부모뷰의 변수의 상태변화 연결)
```swift
부모 View의 상태를 자식 View에 전달함과 동시에
자식 View에서 전달받은 부모View의 상태를 변경할수 있게해준다.

struct ContentView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
                .font(.largeTitle)

            Button(action: {
                count += 1
            }) {
                Text("Increment")
            }
            CounterView(count: $count)
        }
    }
}
struct CounterView: View {

    @Binding var count: Int

    var body: some View {
        Text("Count: \(count)")
            .font(.largeTitle)

        Button(action: {
            count += 1
        }) {
            Text("Increment")
        }
    }
}

위 코드를 실행시켜보면
부모뷰에서 버튼을 누르던, 자식뷰에서 버튼을 누르던
부모뷰 자식뷰 모두에게 반영되는것을 볼수 있다
```
     
### 3. @AppStorage (UserDefaults값의 상태변화 관찰)
```swift
앱의 UserDefaults에 값을 저장하고 읽는데 사용한다.

struct ContentView: View {
    @AppStorage("userName") var username: String = "Guest"

    var body: some View {
        VStack {
            Text(username)
        }
        .onAppear {
            if let username = UserDefaults.standard.string(forKey: "userName") {
                print("debug \(username)")
            }
        }
    }
}

주의할점은 여기서 실행해보면 아무런 로그가 안찍히는것을 볼수 있는데
이유는 앱을 처음켰을때 저렇게 선언만 한다고해서 Guest가 UserDefaults에 저장되는것은 아니다.

username = "가나다"

를 꼭 해줘야 그때부터 저장이 되기 시작한다.
```

### 4. @Environment (전역 환경 변수 상태변화 관찰)
```swift
뷰의 환경값 앱의 전역적인 상태를 가져오는 PropertyWrapper이다.
예를들어 
    struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            if colorScheme == .dark {
                Text("다크모드")
            }
        }
    }
}

처럼 디바이스가 다크모드인지 알수도 있고



struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: ContentView()) {
                    Text("열기")
                }
                Button("닫기") {
                    dismiss()
                }
            }
        }
    }
}

처럼 현재 View를 View계층에서 닫을수도 있다.



이처럼 앱의 전역에서 사용되는 전역 환경 상태값을 가져올수 있다.

또한 이 환경값은 커스텀할수도 있다.

먼저 Key를 먼저 정의해주고 전영상수로 defaultValue라는 이름의 상수를 선언해줘야한다.

struct CustomValueKey: EnvironmentKey {
    static let defaultValue: String = "Default Value"
}

그리고 환경 확장을 이용해 getter setter를 정의하면 된다.

extension EnvironmentValues {
    var customValue: String {
        get { self[CustomValueKey.self] }
        set { self[CustomValueKey.self] = newValue }
    }
}

struct ContentView: View {

    @Environment(\.customValue) var customValue

    var body: some View {
        VStack {
            Text(customValue)
        }
    }
}


또한 View의 modifier의 .environment를 이용해
특정뷰 또는 계층에 대해 각각의 환경 변수를 세팅해줄수도 있다.

    ContentView()
        .environment(\.colorScheme, .dark)
                
    ContentView()
        .environment(\.customValue, "가나다라마바사")
        
```

### 5. @StateObject & @ObservedObject (ObservableObject객체의 상태변화 관찰 (안에서 생성 vs 밖에서 주입))
```swift
ObservableObject란 프로토콜이며 구조체엔 채택할수 없고 class만 채택 가능하다.
그 이유는 ObservableObject는 안에 @Published로 마킹된 프로퍼티는 값이 변경될때 objectWillChange 퍼블리셔를 통해 상태 변화를 알린다.
이를통해 SwiftUI는 상태의 변화를 응답받고 View를 다시 그리게 된다.
값타입은 인스턴스의 복사로 인해 상태의 변경을 추적하고 공유하여 모든 View에 반영하는것 어렵기 때문에 Strut에는 채택할수 없다.

class DataModel: ObservableObject {
    @Published var value: Int = 0

    func increment() {
        value += 1
    }
}

기본적으로는 이렇게 되어 있다.
@Published가 마킹된 프로퍼티가 변경되면 View를 다시그리라고 알린다.
물론 내가 원하는 시점에 View를 다시 그리라고도 할수도 있다.

class DataModel: ObservableObject {
    var value: Int = 0

    func increment() {
        value += 1
        if value > 5 {
            objectWillChange.send()
        }
    }
}
이렇게 수동으로 5보다 클때만 View를 다시그리게도 할수 있다.

@StateObject 그리고 @ObservedObject 둘다 ObservableObject객체의 상태 변화를 관잘하기 위한 ProeprtyWraaper이다.

하지만 명확한 한가지 차이점이 존재하는데

@StateObject를 통해서 관찰되고 있는 객체는
그들을 가지고 있는 화면 구조가 재생성되어도 파괴되지 않는다.
이게 무슨소리냐면
아래 코드를 보면 이해가 빠르다

class DataModel: ObservableObject {
   @Published var value: Int = 0

    func increment() {
        value += 1
    }
}

struct StateObjectView: View {

    @StateObject var model = DataModel()

    var body: some View {
        VStack {
            Text("State")
            Text(String(model.value))
            Button("Increment") {
                model.increment()
            }
        }
    }
}

struct ObservedObjectView: View {

    @ObservedObject var model = DataModel()

    var body: some View {
        VStack {
            Text("Observed")
            Text(String(model.value))
            Button("Increment") {
                model.increment()
            }
        }
    }
}

struct ContentView: View {

    @State var toggle = false

    var body: some View {
        VStack {
            StateObjectView()
            ObservedObjectView()

            Toggle("Toggle", isOn: $toggle)
        }
    }
}

ContentView의 Toggle버튼을 누르면 SwiftUI는 Toggle 버튼을 다시 그리게된다.
toggle 변수의 상태값이 달라졌기때문이다.
이런경우 @OservedObject의 경우 카운터를 올리고 토글버튼을 누르게되면
값이 초기화 된다.
하지만 @StateObject는 그대로 유지된다.

이러한 차이처럼
다른 View의 부분에서 화면이 다시 그려질수 있는 가능성이 있을때 
    @ObservedObject var model: DataModel
이렇게 외부에서 객체를 주입하지 않고 ObservableObject 객체의 상태를 유지해야한다면 @StateObject를 사용하면 된다.

반대로 외부에서 ObservableObject를 주입해서 사용할때는
그냥 @ObservedObject를 사용하면된다.
그래서 안에서 생성할때 @State, 외부에서 주입할땐 @Observed를 사용하면 된다는 것이다.
```

### 6. @EnvironmentObject (ObservableObject객체를 암시적으로 View계층 전체에 전달)
```swift
위의 예시를 들고와서
만약 ObservableObject 객체를 자식의 자식View에 전달해야 한다고 가정해보자.

struct ContentView: View {

    var model = DataModel()

    var body: some View {
        VStack {
            ChildView(model: model)
        }
    }
}

struct ChildView: View {

    @ObservedObject var model: DataModel

    var body: some View {
        VStack {
            ChildView2(model: model)
        }
    }
}


struct ChildView2: View {

    @ObservedObject var model: DataModel

    var body: some View {
        VStack {
            Text(String(model.value))

            Button("increment") {
                model.increment()
            }
        }
    }
}

그럼 이렇게 ChildView에서는 사용하지도 않지만 일단 주입을 받아서 다음 ChildView2에게 넘겨줘야 할것이다.
이렇게 View계층 전체에서 어디에서 쓰일지 모르는 ObservableObject를 전달할때 유용한 ProeprtyWraaper가 바로 @EnvironmentObject 이다.
한번 바꿔보자

struct ContentView: View {

    var model = DataModel()

    var body: some View {
        VStack {
            ChildView()
                .environmentObject(model)
        }
    }
}

struct ChildView: View {

    var body: some View {
        VStack {
            ChildView2()
        }
    }
}

struct ChildView2: View {

    @EnvironmentObject var model: DataModel

    var body: some View {
        VStack {
            Text(String(model.value))

            Button("increment") {
                model.increment()
            }
        }
    }
}

이렇게 되면 ChildView는 model이 필요없기때문에 사용하지않고
ChildView2만 사용할수 있게된것을 볼 수 있을것이다.
```

### 7. @FocusState (텍스트입력을하는 View의 포커스 상태 관리)
```swift
SwiftUI의 text입력을 하는 View의 포커스 상태를 관리할수 있는 PropertyWrapper이다.

struct ContentView: View {

    @FocusState private var textField: Bool
    @FocusState private var textEditor: Bool

    @State var textFieldText = ""
    @State var textEditorText = ""


    var body: some View {
        VStack {
            TextField("", text: $textFieldText)
                .focused($textField)

            TextEditor(text: $textEditorText)
                .focused($textEditor)

            Button("textField") {
                textField.toggle()
            }

            Button("textEditor") {
                textEditor.toggle()
            }
        }
    }
}
```

### 8. @GestureState (제스처 상태 관리)
```swift
struct ContentView: View {

    @State private var dragOffset = CGSize.zero

    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 100, height: 100)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        dragOffset = .zero
                    }
            )
    }
}

struct ContentView: View {

    @GestureState private var dragOffset = CGSize.zero

    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 100, height: 100)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset, body: { value, state, transaction in
                        state = value.translation
                    })
            )
    }
}


두 View모두 같은 동작을 한다. @State를 써서 제스처를 관리하는것과 @GestureState를 쓰는것에 차이는
@GestureState는 제스처가 끝나면 상태를 자동으로 초기화 해준다는 점에 있다.
그렇기때문에 제스처 동작이후 값을 초기상태로 되돌리는 제스처에는 @GestureState가 더 적은 코드를 이용해 구현할수 있다.
```

### 9. @SceneStorage (Scene의 상태관리)
```swift
특정 scene 내에서 상태를 저장하고 관리하는 데 사용된다.
예를들어 앱을 껐다 다시 키더라도 어떤 화면을 기억하고 그화면을 보여주고 싶을때가 있는데
그때 사용하는 PropertyWrapper이다.

struct ContentView: View {
    @SceneStorage("selectedTab") private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(1)

            Text("add")
                .tabItem {
                    Label("Profile", systemImage: "plus")
                }
                .tag(2)
        }
    }
}

이렇게 TabBar의 화면을 저장할수도 있고

struct ContentView: View {
    @SceneStorage("navigationPath") private var navigationPathData: Data?
    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("Go to View A", value: "A")
                NavigationLink("Go to View B", value: "B")
                NavigationLink("Go to View C", value: "C")
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "A":
                    Text("View A")
                case "B":
                    Text("View B")
                case "C":
                    Text("View C")
                default:
                    Text("Unknown View")
                }
            }
            .navigationTitle("Home")
        }
        .onAppear(perform: restoreState)
        .onChange(of: path) { _ in
            saveState()
        }
    }

    private func saveState() {
        if let encoded = try? JSONEncoder().encode(path) {
            navigationPathData = encoded
        }
    }

    private func restoreState() {
        if let data = navigationPathData,
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            path = decoded
        }
    }
}

이렇게 네비게이션 Stack에 대한 정보를 저장하는것도 가능하다.
```

### 10. @ScaledMetric (사용자 설정 상태관리)
```swift
@ScaledMetric은 SwiftUI에서 제공하는 속성 래퍼로, 사용자의 시스템 설정에 따라 동적으로 크기를 조절할 수 있는 값을 정의할 때 사용된다.
주로 폰트 크기나 레이아웃 치수를 사용자의 접근성 설정에 맞게 자동으로 조정하고자 할 때 유용하다.

struct ContentView: View {
    @ScaledMetric var fontSize: CGFloat = 20
    @ScaledMetric(relativeTo: .largeTitle) var imageSize: CGFloat = 100

    var body: some View {
        VStack(spacing: 20) {
            Text("동적으로 크기가 조절되는 텍스트")
                .font(.system(size: fontSize))

            Image(systemName: "star.fill")
                .resizable()
                .frame(width: imageSize, height: imageSize)

            Text("기본 크기의 텍스트")
                .font(.body)
        }
    }
}

이 예제에서 기본 폰트의 경우 20으로 설정하지만
사용자의 시스템 설정에 따라 이값이 자동으로 조정된다.
사용자가 iOS 디바이스 설정에서 더 큰 텍스트 크기를 설정하게되면 이 값도 자동으로 증가한다.

relativeTo 파라미터 같은경우는 이 설정을 세세하게 할수 있따.
사용자의 largeTitle 텍스트 스타일 설정에 따라 iamgeSize도 그에 맞춰 조정되는 것이다.
```

### 11. @FetchRequest (CoreData 상태관리)
```swift
CoreData와 함께 사용되며 CoreData에서 데이터를 가져와 SwiftUI View를 업데이트한다.

// Core Data Stack 설정
class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

@main
struct propertyWraaperTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


struct ContentView: View {
    // @FetchRequest를 사용하여 TextModel 엔티티의 모든 항목을 가져옵니다.

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: TextModel.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TextModel.text, ascending: true)]
    ) var textModels: FetchedResults<TextModel>

    @State private var newText: String = ""
    
    
    var body: some View {
        Form {
            TextField("", text: $newText)
            Button("Add") {
                addItem()
            }
        }
        
        List {
            ForEach(textModels, id: \.self) { textModel in
                Text(textModel.text ?? "No Text")
            }
        }
        .navigationTitle("Text Models")
    }

    private func addItem() {
         withAnimation {
             let newTextModel = TextModel(context: viewContext)
             newTextModel.text = newText

             do {
                 try viewContext.save()
                 newText = ""
             } catch {
                 let nsError = error as NSError
                 fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
             }
         }
     }
}

```

### 12. @UIApplicationDelegateAdaptor (UIKit AppDelegate 상태관리)
```swift
SwiftUI를 사용하는데 UIkit의 AppDelegate 이벤트를 활용할수 있게 해주는 PropertyWraaper이다.

// AppDelegate 클래스 정의
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("애플리케이션이 시작되었습니다.")
        return true
    }
}

@main
struct propertyWraaperTestApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

```

### @Namespace (애니메이션 상태관리)
```swift
SwiftUI에서 애니메이션 전환을 위한 고유한 식별자를 생성하는 사용된다.
.matchedGeometryEffect 와 같이 쓰인다.

struct ContentView: View {
    @Namespace private var animation
    @Namespace private var animation2
    @State private var isExpanded = false

    var body: some View {
        VStack {
            if !isExpanded {
                HStack {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .frame(width: 50, height: 50)
                            .matchedGeometryEffect(id: "rectangle\(index)", in: animation)
                    }
                }
            } else {
                VStack {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                            .frame(height: 100)
                            .matchedGeometryEffect(id: "rectangle\(index)", in: animation)
                    }
                }
            }

            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                Text(isExpanded ? "Collapse" : "Expand")
            }
            .padding()
        }
    }
}

.matchedGeometryEffect가 적용된곳을 보면
각 View에 고유한 ID를 부여하고 @Namespace와 연결한다.
그렇게 되면 SwiftUI는 같은 ID를 사용하는 두개의 다른 View를 같은것으로 인식하여
View의 위치, 크기, 모양 등을 기준으로 애니메이션을 적용한다.
View의 위치나 크기 모양이 급변하게 변하기보단 점진적으로 변하기때문에 더 원할한 애니메이션이 적용되게 된다.
 
``` 

### @AccessilbilityFocusState (접근성 포커스 상태관리)
```swift
SwiftUI에서 접근성 포커스를 관리하는데 사용되는 프로퍼티 래퍼이다.
VoiceOver와 같은 접근성 기능을 사용하는 사용자들에게 중요하다.
이것을 사용하면 프로그래밍 방식으로 접근성 포커스를 제어할수 있다.

struct ContentView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var isSubmitted = false

    @AccessibilityFocusState private var isNameFieldFocused: Bool
    @AccessibilityFocusState private var isEmailFieldFocused: Bool
    @AccessibilityFocusState private var isSubmitButtonFocused: Bool

      var body: some View {
          Form {
              Section(header: Text("Personal Information")) {
                  TextField("Name", text: $name)
                      .accessibilityFocused($isNameFieldFocused)

                  TextField("Email", text: $email)
                      .accessibilityFocused($isEmailFieldFocused)
              }

              Section {
                  Button("Submit") {
                      isSubmitted = true
                      // 제출 후 포커스를 이름 필드로 이동
                      isNameFieldFocused = true
                  }
                  .accessibilityFocused($isSubmitButtonFocused)
              }
          }
          .onChange(of: isSubmitted) { newValue in
              if newValue {
                  // 제출 성공 메시지를 표시하고 포커스를 버튼으로 이동
                  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                      isSubmitButtonFocused = true
                  }
              }
          }
          .onAppear {
              // 뷰가 나타날 때 이름 필드에 포커스
              isNameFieldFocused = true
          }
      }
}

```

### @Observable (class 객체의 상태관리)
```swift
iOS 17부터 도입된 새로운 프로퍼티 래퍼이며.
이는 클래스를 관창 가능한 객체로 만들어 SwiftUI의 View에서 감지하고 UI를 업데이트할 수 있게 만들어준다.
이는 @ObservableObject와 같지만 @ObservableObject와는 다르게 프로퍼티 단위가 아닌 객체 전체를 관찰할 수 있게해주고 또한 더 쉽고 간편하게 상태관리를 할 수 있게해준다.

@Observable
class UserProfile {
    var name: String
    var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

struct ContentView: View {
    @State private var profile = UserProfile(name: "John", age: 30)

    var body: some View {
        VStack {
            Text("Name: \(profile.name)")
            Text("Age: \(profile.age)")
            Button("Increment Age") {
                profile.age += 1
            }
        }
    }
}


```

### @Bindable (@Observable 객체를 양방향 바인딩)
```swift
@ObservedObject를 대체해 @Observable 객체를 양방향의 바인딩을 할수 있게 해주는 ProeprtyWrapper이다.
역시나 iOS17부터 도입됐다.

@Observable
class TextClass {
    var text: String = ""
}

struct ContentView: View {
    @State var text: TextClass = .init()
    var body: some View {
        Form {
            Text(text.text)
            Button("upup") {
                text.text += "1"
            }
        }
        Form {
            ChildView(text: text)
        }
    }
}

struct ChildView: View {

    @State var text: TextClass

    var body: some View {
        Text (text.text)
        Button("upup Child") {
            text.text += "2"
        }
    }
}
```
