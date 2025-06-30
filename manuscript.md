---
title: Package.swiftから始めるSwift 6対応
author: '417.72KI (Twitter @417_72ki / GitHub: 417-72KI)'
papersize: a4
geometry: margin=20mm
header-includes: |
  <style>
    div.sourceCode { background-color: #ffffff; }
    pre.sourceCode:before { border: 1px solid #2a211c; content: " "; position: absolute; z-index: -1; }
    pre.sourceCode { line-height: 16px; border: 1px solid #2a211c; padding:8px; }
    pre code.sourceCode { white-space: pre-wrap; position: relative; }

    div.sourceCode code.swift { color: #000000; }
    code.swift span.at { color: #9b2393; font-weight: bold; } /* Attribute */
    code.swift span.kw { color: #9b2393; font-weight: bold; } /* Keyword */
    code.swift span.fu { color: #9b2393; font-weight: bold; } /* Function */
    code.swift span.cf { color: #9b2393; font-weight: bold; } /* ControlFlow */

    code.swift span.dv { color: #1c00cf; } /* DecVal */
    code.swift span.st { color: #c41a16; } /* String */

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
Swift 6がリリースされてからまもなく1年が経過しようとしていますが、数々のUpcoming Feature FlagsやStrict Concurrency Checkingによる影響度合いの大きさからSwift 6モードに完全移行が叶ったプロダクトはまだまだ多くないのではないでしょうか。
そしてそれはOSSとして公開されているライブラリも同様です。

一方、Upcoming Feature FlagsやStrict Concurrency Checkingは段階的に適用させることが可能です。
そしてそれらはPackage.swiftの差分として可視化できます。

本稿では、Swift Packageで公開しているライブラリをSwift 6に対応させるためにPackage.swiftを魔改造した過程を紹介します。

## セクション

## 終わりに
