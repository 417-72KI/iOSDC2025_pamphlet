---
title: Package.swiftから始めるSwift 6対応
author: '417.72KI (Twitter @417_72ki / GitHub: 417-72KI)'
papersize: a4
geometry: margin=20mm
header-includes: |
  <style>
    div.sourceCode { background-color: #ffffff; }
    pre.sourceCode:before { border: 1px solid #2a211c; content: " "; position: absolute; z-index: -1; }
    pre.sourceCode { line-height: 16px; border: 1px solid #2a211c; }
    pre code.sourceCode { white-space: pre-wrap; position: relative; }

    div.sourceCode code.swift { color: #000000; }
    code.swift span.at { color: #9b2393; font-weight: bold; } /* Attribute */
    code.swift span.kw { color: #9b2393; font-weight: bold; } /* Keyword */
    code.swift span.fu { color: #9b2393; font-weight: bold; } /* Function */
    code.swift span.cf { color: #9b2393; font-weight: bold; } /* ControlFlow */

    code.swift span.dv { color: #1c00cf; } /* DecVal */
    code.swift span.st { color: #c41a16; } /* String */

    code.swift span.co { color: #5d6c79; font-style: normal; font-weight: normal; } /* Comment out */

    div.sourceCode pre.sh { background-color: #000000; }
    div.sourceCode code.bash { color: #28fe14; }
    code.bash span.kw { color: #28fe14; font-weight: bold; }
    code.bash span.er { color: #28fe14; font-weight: bold; }

    # ul { margin: -5px 0; }
    ul li { margin: 10px 0; }
    ol li { margin: 3px 0; }
  </style>
---

## はじめに
Swift 6がリリースされてからまもなく1年が経過しようとしていますが、数々のUpcoming Feature FlagsやStrict Concurrency Checkingによる影響度合いの大きさからSwift 6モードに完全移行が叶ったプロダクトは、まだまだ多くないのではないでしょうか。
そしてそれはOSSとして公開されているライブラリも同様です。

一方、Upcoming Feature FlagsやStrict Concurrency Checkingは段階的に適用させることが可能です。
そしてそれらはPackage.swiftの差分として可視化できます。

本稿では、Swift Packageで公開しているライブラリをSwift 6対応させるためにPackage.swiftを魔改造した過程を紹介します。

(ここまでプロポーザルの説明文)

## Package.swiftの構造
Package.swiftはSwift Package Managerの設定ファイルであり、Swift Packageのメタデータを定義します。

シンプルなPackage.swiftの例を以下に示します。

```swift
// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "MyLibrary",
  products: [
    .library(
      name: "MyLibrary",
      targets: ["MyLibrary"]
    ),
  ],
  targets: [
    .target(name: "MyLibrary"),
    .testTarget(
      name: "MyLibraryTests",
      dependencies: ["MyLibrary"]
    ),
  ]
)
```

勘のいい人であればPackage.swiftもただのSwiftコードであることに気づくはずです。
また、*Jump to Definition* 等によって `Package` が `class` であることも分かります。

つまり、このPackage.swiftはSwift Package Managerの設定を定義するための`Package`オブジェクトを生成しているに過ぎません。

## Package.swiftとUpcoming Feature Flags
このPackage.swiftにUpcoming Feature Flagsを追加することで、Swift 6の新機能を段階的に有効化できます。
以下は、有志の作成したチートシート[^1]をベースにUpcoming Feature Flagsを追加した例です。

```swift
let package = Package(
  ...
  targets: [
    .target(name: "MyLibrary", swiftSettings: [.existentialAny])
  ]
)

// ※以降のコードでは省略
extension SwiftSetting {
  static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")
  ...
}
```

一見これで良さそうに見えますが、例えばtargetが複数になったらどうでしょうか？
```swift
targets: [
  .target(name: "MyLibrary", swiftSettings: [.existentialAny]),
  .target(name: "SubLibrary"),
]
```

この場合、MyLibraryのみにUpcoming Feature Flagsが適用され、SubLibraryには適用されません。
そのため、全てのtargetにUpcoming Feature Flagsを適用するには都度 `swiftSettings` を追加します。

```swift
targets: [
  .target(name: "MyLibrary", swiftSettings: [.existentialAny]),
  .target(name: "SubLibrary", swiftSettings: [.existentialAny]),
]
```

しかし、これでは新しいtargetが追加されるたびに手動で設定を追加しなければなりません。
そこで、Package.swiftの構造を利用して、全てのtargetにUpcoming Feature Flagsを適用する方法を考えます。

`targets`を見てみると`Target`型の配列であること、そして`Target`は`Package`と同じく`class`であることが分かります。
つまり、以下のように書けます。

```swift
let package = Package(...)

package.targets.forEach { target in
  target.swiftSettings = [
    // .forwardTrailingClosures, // コメントアウトで無効にできる
    .existentialAny,
    .bareSlashRegexLiterals,
    .conciseMagicFile,
    .importObjcForwardDeclarations,
    .disableOutwardActorInference,
    .deprecateApplicationMain,
    .isolatedDefaultValues,
    .globalConcurrency,
  ]
}
```

[^1]:https://github.com/treastrain/swift-upcomingfeatureflags-cheatsheet

こうすることで、全てのtargetにまとめてUpcoming Feature Flagsを適用できます。
また、Swift 6以降の新しいUpcoming Feature Flagsも、上記の配列に追加するだけで適用できます。

## Package.swift と Strict Concurrency Checking
Strict Concurrency Checkingを`Complete`にすることでPackage全体のSendable制約とアクター隔離のチェックをします。
Package.swiftでStrict Concurrency Checkingを適用するには、`target.swiftSettings`に`enableExperimentalFeature("StrictConcurrency")`を追加します[^2]。

[^2]:https://www.swift.org/documentation/concurrency/

つまり先述と同様、以下のように書くことができます。

```swift
package.targets.forEach { target in
  var settings = target.swiftSettings ?? []
  settings.append(.enableExperimentalFeature("StrictConcurrency"))
  target.swiftSettings = settings
}
```

## おまけ: 開発 / テストでだけ必要なライブラリの取り扱い
リリース時には不要でも開発やテストの際に使用しているライブラリがあります。
過去に書いたQiitaの記事[^3]があるのですが、これも以下のように直すことができます。

```swift
let isDevelop = true // タグを切る時に`false`にする

if isDevelop {
  package.dependencies.append(contentsOf: [
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.57.0"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.0"),
    .package(url: "https://github.com/ishkawa/APIKit.git", from: "5.4.0"),
  ])
  package.targets
    .filter(\.isTest) // `.testTarget` のみに適用される
    .forEach { target in
      target.dependencies.append(contentsOf: [
        "Alamofire",
        "APIKit",
      ])
  }
  package.targets.forEach { target in // 全てのtargetに適用される
    if target.plugins == nil {
      target.plugins = []
    }
    target.plugins?.append(.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins"))
  }
}
```

[^3]:https://qiita.com/417_72ki/items/9e1efa14483768a8ff76

## 終わりに
最終的に出来上がったものは長くなるのでここでは割愛します。
筆者が個人で公開しているライブラリ[^4]が複数あるので、興味がある方はぜひご覧ください。

[^4]:https://github.com/417-72KI?tab=repositories&q=&type=source&language=swift

今回Package.swiftを魔改造することで、Swift 6への対応をスムーズに行う方法を紹介しました。
Package.swiftのコード差分としてUpcoming Feature FlagsやStrict Concurrency Checkingの適用状況を可視化できるため、開発者はどの機能が有効化されているか、また有効化したことで必要となった修正を簡単に把握できます。

また、この方法はSwift Package Managerの設定を柔軟に変更できることを示しており、将来のSwiftのアップデートにも対応しやすくなります。

Package.swiftがただの設定ファイルではなく**Swiftコード**であることに気づくと、色々な改造の可能性が見えてくることが分かります。
今回紹介した方法以外にもPackage.swiftの構造を活用する方法はあるはずです。
皆さんも是非色々な可能性を探してみてください。
