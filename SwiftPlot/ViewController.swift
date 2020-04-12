//
//  ViewController.swift
//  SwiftPlot
//
//  Created by Jeff Terry on 4/12/20.
//  Copyright © 2020 Jeff Terry. All rights reserved.
//

import Cocoa
import CorePlot

class ViewController : NSViewController, CPTScatterPlotDataSource, CPTAxisDelegate {
    private var scatterGraph : CPTXYGraph? = nil
    @IBOutlet weak var hostingView: CPTGraphHostingView!

    typealias plotDataType = [CPTScatterPlotField : Double]
    private var dataForPlot = [plotDataType]()

    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
         makePlot(xLabel: "", yLabel: "", xMin: -1, xMax: 1, yMin: -1, yMax: 1)
        

    }

    /// Calculates the points of the function exp(-x) and adds them as (x,y) points to the contentArray for display
    ///
    /// - Parameter sender: Sending Object Address
    @IBAction func updatePlot(_ sender: Any) {

        let axisLabelX = "X"
        let axisLabelY = "Yvalue"
        let MinXDisplayCoord = -0.5
        let MaxXDisplayCoord = 1.5
        let MinYDisplayCoord = -0.25
        let MaxYDisplayCoord = 1.25

        
        dataForPlot = []

        for i in 0 ..< 60 {

            //create x values here

            let x = -2.0 + Double(i) * 0.2

        //create y values here

            let y = exp(-x)


            let dataPoint: plotDataType = [.X: x, .Y: y]
            dataForPlot.append(dataPoint)
        }

        makePlot(xLabel: axisLabelX, yLabel: axisLabelY, xMin: MinXDisplayCoord, xMax: MaxXDisplayCoord, yMin: MinYDisplayCoord, yMax: MaxYDisplayCoord)
    }

    /************** Functions for Plotting **************/


    /// makePlot sets up the default plotting conditions and displays the data
    func makePlot(xLabel: String, yLabel: String, xMin: Double, xMax: Double, yMin: Double, yMax: Double) {

        // Create graph from theme
        let newGraph = CPTXYGraph(frame: .zero)
        newGraph.apply(CPTTheme(named: .darkGradientTheme))

        hostingView.hostedGraph = newGraph

        // Paddings
        newGraph.paddingLeft   = 10.0
        newGraph.paddingRight  = 10.0
        newGraph.paddingTop    = 10.0
        newGraph.paddingBottom = 10.0

        // Plot space
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true

        plotSpace.yRange = CPTPlotRange(location: yMin as NSNumber, length: (yMax - yMin) as NSNumber)
        plotSpace.xRange = CPTPlotRange(location: xMin as NSNumber, length: (xMax - xMin) as NSNumber)

        // Anotation

        let theTextStyle = CPTMutableTextStyle()

        theTextStyle.color =  .white()

        let ann = CPTLayerAnnotation.init(anchorLayer: hostingView.hostedGraph!.plotAreaFrame!)

        ann.rectAnchor = .bottom; // to make it the top centre of the plotFrame
        ann.displacement = CGPoint(x: 20.0, y: 20.0) // To move it down, below the title

        let textLayer = CPTTextLayer.init(text: xLabel, style: theTextStyle)

        ann.contentLayer = textLayer

        hostingView.hostedGraph?.plotAreaFrame?.addAnnotation(ann)

        let annY = CPTLayerAnnotation.init(anchorLayer: hostingView.hostedGraph!.plotAreaFrame!)

        annY.rectAnchor = .left; // to make it the top centre of the plotFrame
        annY.displacement = CGPoint(x: 50.0, y: 30.0) // To move it down, below the title

        let textLayerY = CPTTextLayer.init(text: yLabel, style: theTextStyle)
        let angle = CGFloat.pi/2.0

        annY.contentLayer = textLayerY
        annY.rotation = angle;
        
        
        hostingView.hostedGraph?.plotAreaFrame?.addAnnotation(annY)

        // Axes
        let axisSet = newGraph.axisSet as! CPTXYAxisSet

        if let x = axisSet.xAxis {
            x.majorIntervalLength   = 1.0
            x.orthogonalPosition    = 0.0
            x.minorTicksPerInterval = 3
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 0.5
            y.minorTicksPerInterval = 5
            y.orthogonalPosition    = 0.0
            y.delegate = self
        }

        // Create a blue plot area
        let blueLineStyle = CPTMutableLineStyle()
        blueLineStyle.miterLimit    = 1.0
        blueLineStyle.lineWidth     = 3.0
        blueLineStyle.lineColor     = .blue()

        let linePlot = CPTScatterPlot(frame: .zero)
        linePlot.dataLineStyle = blueLineStyle
        linePlot.identifier    = "Blue Plot" as NSString
        linePlot.dataSource    = self
        linePlot.interpolation = .curved
        newGraph.add(linePlot)

        // Add plot symbols
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = .black()
        let plotSymbol = CPTPlotSymbol.ellipse()
        plotSymbol.fill          = CPTFill(color: .blue())
        plotSymbol.lineStyle     = symbolLineStyle
        plotSymbol.size          = CGSize(width: 10.0, height: 10.0)
        linePlot.plotSymbol = plotSymbol

        self.scatterGraph = newGraph
    }

    // MARK: - Plot Data Source Methods
    func numberOfRecords(for plot: CPTPlot) -> UInt
    {
        return UInt(self.dataForPlot.count)
    }

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any?
    {
        let plotField = CPTScatterPlotField(rawValue: Int(field))

        if let num = self.dataForPlot[Int(record)][plotField!] {
            return num as NSNumber
        }
        else {
            return nil
        }
    }

    // MARK: - Axis Delegate Methods
    func axis(_ axis: CPTAxis, shouldUpdateAxisLabelsAtLocations locations: Set<NSNumber>) -> Bool
    {
        if let formatter = axis.labelFormatter {
            let labelOffset = axis.labelOffset

            var newLabels = Set<CPTAxisLabel>()

            for location in locations {
                if let labelTextStyle = axis.labelTextStyle?.mutableCopy() as? CPTMutableTextStyle {
                    if location.doubleValue >= 0.0 {
                        labelTextStyle.color = .green()
                    }
                    else {
                        labelTextStyle.color = .red()
                    }

                    let labelString   = formatter.string(for:location)
                    let newLabelLayer = CPTTextLayer(text: labelString, style: labelTextStyle)

                    let newLabel = CPTAxisLabel(contentLayer: newLabelLayer)
                    newLabel.tickLocation = location
                    newLabel.offset       = labelOffset
                    
                    newLabels.insert(newLabel)
                }
                
                axis.axisLabels = newLabels
            }
        }
        
        return false
    }
}


