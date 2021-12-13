//
//  Day_13_VisualizedApp.swift
//  Day 13 Visualized
//
//  Created by Stephen H. Gerstacker on 2021-12-13.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import SwiftUI
import Utilities

let InputData = """
201,376
706,92
161,698
970,597
751,579
1031,337
975,73
800,520
782,427
316,332
838,793
388,653
507,590
1299,471
547,368
771,169
152,562
422,110
279,844
338,556
45,135
447,560
704,231
759,586
271,686
505,141
423,262
915,716
730,52
773,113
1099,787
821,157
771,452
940,95
618,327
1193,781
243,677
907,427
878,84
13,576
1068,705
371,777
617,518
1308,304
972,108
375,221
213,481
445,891
576,427
13,800
899,5
209,451
895,787
119,75
231,7
398,477
652,131
1213,142
1004,885
182,744
805,753
609,563
997,38
161,681
1058,612
920,535
537,787
510,598
112,628
775,112
1210,232
1057,288
833,212
517,621
913,51
1051,850
321,158
1230,474
281,555
591,77
387,483
567,555
1195,868
1255,304
833,234
1297,128
627,80
800,325
144,807
813,98
375,306
1160,521
395,268
888,40
952,99
137,22
730,500
446,432
541,553
351,417
103,770
1160,376
1305,434
535,782
132,773
1116,317
428,406
572,866
1034,479
705,5
1233,117
584,173
95,439
1028,175
1019,191
107,63
986,467
927,238
952,739
1163,304
236,273
113,329
1079,7
1143,333
1102,544
266,653
321,766
477,72
118,47
244,84
803,309
1139,297
1131,227
1097,665
1290,233
248,875
878,138
932,479
997,576
410,588
1178,129
208,399
1150,413
314,376
1195,508
375,140
542,640
447,117
239,869
594,465
1265,135
166,859
961,210
539,844
831,124
1160,518
199,358
78,91
571,453
438,656
1031,82
92,51
329,605
248,355
1019,73
676,618
447,777
418,173
276,267
624,347
700,784
631,645
117,337
324,63
208,462
418,336
249,777
617,777
746,721
78,427
580,388
1,728
1225,515
505,753
169,46
667,759
557,142
892,336
219,880
676,113
1044,653
756,337
643,583
1283,80
822,483
1243,821
483,521
771,841
1193,787
213,665
1029,339
734,427
1126,233
509,805
1280,541
1168,233
147,309
137,424
1031,140
112,266
264,406
1133,10
557,501
453,789
435,883
855,205
150,521
60,465
393,421
62,712
750,110
1228,425
259,355
915,178
77,565
331,341
846,236
1034,316
771,420
35,213
1262,327
679,29
1120,684
248,467
1195,634
1215,439
584,621
1235,606
1116,345
264,751
242,721
179,451
213,229
1019,302
462,406
1130,159
1091,238
515,403
935,620
790,854
671,277
552,317
164,26
853,218
570,497
743,124
1043,770
1004,9
488,338
398,108
390,535
1051,178
580,52
1029,347
624,547
1019,816
522,129
771,681
348,676
1183,88
107,816
361,844
1173,424
117,557
768,254
432,756
1173,872
975,631
1141,686
242,705
350,698
291,738
1262,231
959,417
1197,565
580,836
82,306
1121,415
1091,880
338,142
1263,306
647,64
576,539
1275,213
475,3
1061,221
1151,378
358,255
244,588
1280,99
1021,406
503,23
1273,264
1029,107
1193,561
867,841
442,567
878,532
875,11
838,471
870,752
84,136
107,192
276,130
353,584
184,732
589,421
920,488
1007,865
497,98
985,810
1093,490
584,72
1163,309
636,612
10,332
539,634
1079,262
539,50
674,242
306,885
989,766
539,814
316,752
515,851
592,346
79,665
333,766
1126,661
1093,30
771,260
485,46
763,721
1141,298
1039,686
460,317
1044,484
1141,46
997,190
791,142
773,883
45,555
488,483
813,654
441,481
443,218
180,159
353,264
903,653
773,107
817,196
47,501
1014,292
835,3
395,455
1223,555
653,728
643,759
100,337
87,339
340,824
835,30
44,558
323,341
10,310
507,585
751,455
1074,173
668,373
314,297
557,752
1,241
545,864
415,107
927,623
393,473
1309,241
609,555
303,417
836,735
12,294
935,74
617,329
970,70
1121,424
751,178
1256,702
7,745
1298,294
1308,831
441,665
658,859
1163,585
1193,557
87,572
1144,427
1308,579
1297,94
517,470
773,787
559,663
412,721
560,336
691,563
592,712
139,403
716,465
1232,539
37,672
1232,467
1178,420
1210,337
1054,865
296,99
331,379
966,103
1091,526
1261,889
539,366
1101,99
1054,843
485,688
878,756
552,129
935,221
115,452
405,673
333,340
90,334
972,332
1292,282
160,786
97,714
577,777
855,689
296,558
1145,157
177,10
440,640
517,273
291,156
609,759
1031,86
1166,598
276,764
70,173
1282,376
264,109
479,770
150,742
259,268
559,455
584,721
1046,751
622,567
1308,348
937,339
1241,51
710,864
1019,255
701,135
1205,715
771,396
935,673
339,807
1078,784
718,548
769,553
703,80
661,128
279,116
759,308
605,889
212,567
239,25
483,373
74,500
704,327
1062,427
411,5
358,602
572,693
658,273
607,501
1267,819
18,325
231,262
1088,875
775,560
840,162
78,355
1019,345
75,736
768,714
987,379
1019,144
576,467
915,887
1273,565
107,702
407,205
1002,121
1207,322
850,577
800,449
1245,624
686,344
1273,222
522,773
321,554
721,473
281,339
1207,770
579,606
401,158
683,30
325,885
600,30
763,526
36,327
402,282
485,206
441,105
1062,467
740,136
1265,547
95,268
740,231
1098,327
977,788
527,3
284,543
1144,497
751,329
795,403
1233,565
132,474
912,477
1088,586
999,645
1071,473
987,553
734,539
577,68
997,262
996,376
535,560
915,374
1062,355
701,759
387,348
1149,157
1021,488
1261,453
10,732
887,231
435,511
226,680
657,166
892,173
398,193
610,784
171,297
480,114
539,841
30,353
1120,210
986,103
142,233
517,490
987,515
1160,742
2,348
338,835
837,537
653,241
405,565
428,886
147,366
1191,782
1178,773
346,121
980,383
683,416
1141,240
117,561
545,416
497,512
497,298
545,30
971,87
835,366
475,30
446,544
522,325
30,795
395,520
773,435
259,850
1292,886
20,233
935,588
912,865
432,532
1061,603
607,80
743,158
266,241
55,418
835,443
536,495
217,30
518,12
959,477
823,561
1205,179
211,218
1191,334
422,40
209,99
611,777
105,179
771,617
865,795
115,528
1155,297
616,176
1029,787
390,359
324,103
821,737
283,329
718,751
279,274
1303,512
1223,787
330,19
209,795
1031,50
935,82
177,212
997,318
236,621
273,416
395,374
763,368
146,63
627,478
652,859
5,714
1038,254
820,245
1021,553
822,780
23,29
580,500
244,256
693,777
822,19
37,406
1088,243
945,341
161,868
423,887
825,688
793,490
97,180
323,379
226,458
219,814
539,260
688,327
244,862
1079,745
1067,441
980,511
323,515
507,366
771,814
520,854
718,303
48,327
472,793
788,101
693,518
705,889
179,667
349,684
1305,714
306,9
1051,485
1165,357
740,621
115,501
475,366
657,653
957,584
139,851
642,373
1131,667
1300,310
266,410
330,63
455,877
455,88
1265,583
1305,12
157,512
969,682
899,229
1297,862
666,610
1144,859
979,341
1195,452
346,311
132,121
867,676
1203,816
711,476
219,238
253,736
865,451
817,605
1231,665
94,784
731,19
370,351
822,481
387,411
473,537
442,327
905,221
1091,368
1203,702
45,583
551,138
975,373
338,171
165,289
986,763
570,621
765,416
1265,555
340,597
1102,495
48,567
1091,656
1007,417
324,763
738,866
142,457
1280,795
1002,500
435,686
517,582
315,535
1099,501
989,340
243,217
144,598
59,859
1078,110
10,758
1192,544
166,562
30,541
537,781
1068,861
279,778
1203,831
739,453
63,525
1163,702
259,455
1220,334
1183,437
475,478
939,777
693,329
788,661
865,443
398,865
433,438
1203,397
743,555
863,777
335,73
852,231
580,842
1153,848
539,186
166,411
103,124
211,393
537,435
433,8
977,340
935,250
1164,63
701,331
912,193
850,793
977,460
1178,9
1193,113
626,600
69,843
935,778
331,603
80,420
1116,793
45,759
457,218
504,70
1014,558
1265,759
365,488
923,411
986,131
740,663
686,740
113,105
107,497
279,808
971,535
465,628
10,562
497,382
488,114
600,416
1145,868
1195,834
157,46
644,562
214,852
790,40
686,347
214,42
435,459
184,233
330,348
935,522
774,399
888,110
365,341
1143,561
117,787
2,483
1263,340
515,491
1164,831
1051,455
519,142
947,549
1029,99

fold along x=655
fold along y=447
fold along x=327
fold along y=223
fold along x=163
fold along y=111
fold along x=81
fold along y=55
fold along x=40
fold along y=27
fold along y=13
fold along y=6
"""

enum Fold {
    case horizontal(Int)
    case vertical(Int)
}

struct Paper {

    let width: Int
    let height: Int

    let dots: [[Bool]]

    init(width: Int, height: Int, dots: [[Bool]]) {
        self.width = width
        self.height = height
        self.dots = dots
    }

    init<T: Sequence>(width: Int, height: Int, dotPairs: T) where T.Iterator.Element == (Int, Int) {
        var convertedDots = [[Bool]](repeating: [Bool](repeating: false, count: width), count: height)

        for dot in dotPairs {
            convertedDots[dot.1][dot.0] = true
        }

        self.init(width: width, height: height, dots: convertedDots)
    }

    var totalDots: Int {
        var sum = 0

        for row in dots {
            for value in row {
                sum += value ? 1 : 0
            }
        }

        return sum
    }

    func folded(by fold: Fold) -> Paper {
        switch fold {
        case .horizontal(let line):
            return foldedHorizontally(on: line)
        case .vertical(let line):
            return foldedVertically(on: line)
        }
    }

    /// Fold the paper up along the y-axis
    private func foldedHorizontally(on yAxis: Int) -> Paper {
        // Calculate the new dimensions of the paper
        let topHeight = yAxis
        let bottomHeight = (height - yAxis) - 1

        let nextHeight = max(topHeight, bottomHeight)
        let nextWidth = width

        var nextDots = [[Bool]](repeating: [Bool](repeating: false, count: nextWidth), count: nextHeight)

        // Copy the values from the top
        for srcY in 0 ..< topHeight {
            for srcX in 0 ..< width {
                let destX = srcX
                let destY = srcY

                nextDots[destY][destX] = dots[srcY][srcX]
            }
        }

        // Merge the values from the bottom
        for srcY in (yAxis + 1) ..< height {
            for srcX in 0 ..< width {
                let destX = srcX
                let destY = nextHeight - (srcY - yAxis)

                nextDots[destY][destX] = nextDots[destY][destX] || dots[srcY][srcX]
            }
        }

        let nextPaper = Paper(width: nextWidth, height: nextHeight, dots: nextDots)

        return nextPaper
    }

    /// Fold the paper left along the x-axis
    private func foldedVertically(on xAxis: Int) -> Paper {
        // Calculate the new dimensions of the paper
        let leftWidth = xAxis
        let rightWidth = width - xAxis - 1

        let nextWidth = max(leftWidth, rightWidth)
        let nextHeight = height

        var nextDots = [[Bool]](repeating: [Bool](repeating: false, count: nextWidth), count: nextHeight)

        // Copy the values from the left side
        for srcY in 0 ..< height {
            for srcX in 0 ..< xAxis {
                let destX = srcX
                let destY = srcY

                nextDots[destY][destX] = dots[srcY][srcX]
            }
        }

        // Merge the values from the right
        for srcY in 0 ..< height {
            for srcX in (xAxis + 1) ..< width {
                let destX = nextWidth - (srcX - xAxis)
                let destY = srcY

                nextDots[destY][destX] = nextDots[destY][destX] || dots[srcY][srcX]
            }
        }

        let nextPaper = Paper(width: nextWidth, height: nextHeight, dots: nextDots)

        return nextPaper
    }

    func printPaper(with fold: Fold? = nil) {
        var output = ""

        for (y, line) in dots.enumerated() {
            if !output.isEmpty { output += "\n" }

            output += line.enumerated().map { (x, value) -> String in
                if case .horizontal(let axis) = fold, y == axis {
                    return "-"
                } else if case .vertical(let axis) = fold, x == axis {
                    return "|"
                } else {
                    return value ? "#" : "."
                }
            }.joined()
        }

        print(output)
    }
}

@main
struct Day_13_VisualizedApp: App {
    let initialPaper: Paper
    let folds: [Fold]

    init() {
        var xs: [Int] = []
        var ys: [Int] = []
        var folds: [Fold] = []

        var inFolds = false

        for line in InputData.components(separatedBy: .newlines) {
            if !inFolds && line.isEmpty {
                inFolds = true
                continue
            }

            if inFolds {
                let parts = line.split(separator: "=")
                precondition(parts.count == 2)

                let axis = parts[0].last!
                let amount = Int(parts[1])!

                switch axis {
                case "x":
                    folds.append(.vertical(amount))
                case "y":
                    folds.append(.horizontal(amount))
                default:
                    fatalError("Unhandled axis: \(axis)")
                }
            } else {
                let parts = line.split(separator: ",")
                precondition(parts.count == 2)

                let x = Int(parts[0])!
                let y = Int(parts[1])!

                xs.append(x)
                ys.append(y)
            }
        }

        let width = xs.max()!
        let height = ys.max()!

        initialPaper = Paper(width: width + 1, height: height + 1, dotPairs: zip(xs, ys))
        self.folds = folds
    }

    var body: some Scene {
        WindowGroup {
            RenderableWorkView(width: initialPaper.width, height: initialPaper.height, frameTime: 0.25) { animator in
                var currentPaper = initialPaper

                animator.draw {
                    render(context: $0, paper: currentPaper)
                }

                for fold in folds {
                    animator.draw {
                        render(context: $0, paper: currentPaper, fold: fold)
                    }

                    currentPaper = currentPaper.folded(by: fold)

                    animator.draw {
                        render(context: $0, paper: currentPaper)
                    }
                }
            }
        }
    }

    private func render(context: CGContext, paper: Paper, fold: Fold? = nil) {
        let backgroundColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let blockColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let emptyColor = CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        let foldColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        let blockWidth = CGFloat(context.width) / CGFloat(paper.width)
        let blockHeight = CGFloat(context.height) / CGFloat(paper.height)
        let blockSize = min(blockWidth, blockHeight)

        let drawingWidth = blockSize * CGFloat(paper.width)
        let drawingHeight = blockSize * CGFloat(paper.height)

        let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)
        let drawingBounds = CGRect(
            x: (CGFloat(context.width) - drawingWidth) / 2,
            y: (CGFloat(context.height) - drawingHeight) / 2,
            width: drawingWidth,
            height: drawingHeight
        )

        context.setFillColor(backgroundColor)
        context.fill(backgroundBounds)

        context.setFillColor(emptyColor)
        context.fill(drawingBounds)

        for y in 0 ..< paper.height {
            for x in 0 ..< paper.width {
                let value = paper.dots[y][x]

                guard value else { continue }

                let bounds = CGRect(
                    x: drawingBounds.minX + (blockSize * CGFloat(x)),
                    y: drawingBounds.minY + (blockSize * CGFloat(y)),
                    width: blockSize,
                    height: blockSize
                )

                context.setFillColor(blockColor)
                context.fill(bounds)
            }
        }

        if let fold = fold {
            let line = CGMutablePath()

            switch fold {
            case .horizontal(let axis):
                let point1 = CGPoint(x: drawingBounds.minX, y: drawingBounds.minY + (CGFloat(axis) * blockSize))
                line.move(to: point1)

                let point2 = CGPoint(x: drawingBounds.maxX, y: drawingBounds.minY + (CGFloat(axis) * blockSize))
                line.addLine(to: point2)
            case .vertical(let axis):
                let point1 = CGPoint(x: drawingBounds.minX + (CGFloat(axis) * blockSize), y: drawingBounds.minY)
                line.move(to: point1)

                let point2 = CGPoint(x: drawingBounds.minX + (CGFloat(axis) * blockSize), y: drawingBounds.maxY)
                line.addLine(to: point2)
            }

            context.addPath(line)

            context.setLineWidth(3.0)
            context.setStrokeColor(foldColor)
            context.strokePath()
        }
    }
}
