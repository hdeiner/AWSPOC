/*!
 * Chart.js v3.0.0-master
 * https://www.chartjs.org
 * (c) 2020 Chart.js Contributors
 * Released under the MIT License
 */
interface VisualElement {
  draw(ctx: CanvasRenderingContext2D): void;
  inRange(mouseX: number, mouseY: number, useFinalPosition?: boolean): boolean;
  inXRange(mouseX: number, useFinalPosition?: boolean): boolean;
  inYRange(mouseY: number, useFinalPosition?: boolean): boolean;
  getCenterPoint(useFinalPosition?: boolean): { x: number; y: number };
  getRange?(axis: 'x' | 'y'): number;
}

interface CommonOptions {
  borderWidth: number;
  borderColor: Color;
  backgroundColor: Color;
}

interface CommonHoverOptions {
  hoverBorderWidth: number;
  hoverBorderColor: Color;
  hoverBackgroundColor: Color;
}

interface Segment {
  start: number;
  end: number;
  loop: boolean;
}

interface ArcProps {
  x: number;
  y: number;
  startAngle: number;
  endAngle: number;
  innerRadius: number;
  outerRadius: number;
  circumference: number;
}

interface ArcOptions extends CommonOptions {
  /**
   * Arc stroke alignment.
   */
  borderAlign: 'center' | 'inner';
  /**
   * Arc offset (in pixels).
   */
  offset: number;
}

interface ArcHoverOptions extends CommonHoverOptions {
  hoverOffset: number;
}

interface ArcElement<T extends ArcProps = ArcProps, O extends ArcOptions = ArcOptions>
  extends Element<T, O>,
    VisualElement {}

declare const ArcElement: ChartComponent & {
  prototype: ArcElement;
  new (cfg: any): ArcElement;
};

interface LineProps {}

interface LineOptions extends CommonOptions {
  /**
   * Line cap style. See MDN.
   * @default 'butt'
   */
  borderCapStyle: CanvasLineCap;
  /**
   * Line dash. See MDN.
   * @default []
   */
  borderDash: number[];
  /**
   * Line dash offset. See MDN.
   * @default 0.0
   */
  borderDashOffset: number;
  /**
   * Line join style. See MDN.
   * @default 'miter'
   */
  borderJoinStyle: CanvasLineJoin;
  /**
   * 	true to keep Bézier control inside the chart, false for no restriction.
   * @default true
   */
  capBezierPoints: boolean;
  /**
   * Interpolation mode to apply.
   * @default 'default'
   */
  cubicInterpolationMode: 'default' | 'monotone';
  /**
   * Bézier curve tension (0 for no Bézier curves).
   * @default 0
   */
  tension: number;
  /**
   * true to show the line as a stepped line (tension will be ignored).
   * @default false
   */
  stepped: 'before' | 'after' | 'middle' | boolean;
}

interface LineHoverOptions extends CommonHoverOptions {
  hoverBorderCapStyle: CanvasLineCap;
  hoverBorderDash: number[];
  hoverBorderDashOffset: number;
  hoverBorderJoinStyle: CanvasLineJoin;
}

interface LineElement<T extends LineProps = LineProps, O extends LineOptions = LineOptions>
  extends Element<T, O>,
    VisualElement {
  updateControlPoints(chartArea: ChartArea): void;
  points: Point[];
  readonly segments: Segment[];
  first(): Point | false;
  last(): Point | false;
  interpolate(point: Point, property: 'x' | 'y'): undefined | Point | Point[];
  pathSegment(ctx: CanvasRenderingContext2D, segment: Segment, params: any): undefined | boolean;
  path(ctx: CanvasRenderingContext2D): boolean;
}

declare const LineElement: ChartComponent & {
  prototype: LineElement;
  new (cfg: any): LineElement;
};

interface PointProps {
  x: number;
  y: number;
}

type PointStyle =
  | 'circle'
  | 'cross'
  | 'crossRot'
  | 'dash'
  | 'line'
  | 'rect'
  | 'rectRounded'
  | 'rectRot'
  | 'star'
  | 'triangle'
  | HTMLImageElement
  | HTMLCanvasElement;

interface PointOptions extends CommonOptions {
  /**
   * Point radius
   * @default 3
   */
  radius: number;
  /**
   * Extra radius added to point radius for hit detection.
   * @default 1
   */
  hitRadius: number;
  /**
   * Point style
   * @default 'circle;
   */
  pointStyle: PointStyle;
  /**
   * Point rotation (in degrees).
   * @default 0
   */
  rotation: number;
}

interface PointHoverOptions extends CommonHoverOptions {
  /**
   * Point radius when hovered.
   * @default 4
   */
  hoverRadius: number;
}

interface PointPrefixedOptions {
  /**
   * The fill color for points.
   */
  pointBackgroundColor: Color;
  /**
   * The border color for points.
   */
  pointBorderColor: Color;
  /**
   * The width of the point border in pixels.
   */
  pointBorderWidth: number;
  /**
   * The pixel size of the non-displayed point that reacts to mouse events.
   */
  pointHitRadius: number;
  /**
   * The radius of the point shape. If set to 0, the point is not rendered.
   */
  pointRadius: number;
  /**
   * The rotation of the point in degrees.
   */
  pointRotation: number;
  /**
   * Style of the point.
   */
  pointStyle: PointStyle;
}

interface PointPrefixedHoverOptions {
  /**
   * Point background color when hovered.
   */
  pointHoverBackgroundColor: Color;
  /**
   * Point border color when hovered.
   */
  pointHoverBorderColor: Color;
  /**
   * Border width of point when hovered.
   */
  pointHoverBorderWidth: number;
  /**
   * The radius of the point when hovered.
   */
  pointHoverRadius: number;
}

interface PointElement<T extends PointProps = PointProps, O extends PointOptions = PointOptions>
  extends Element<T, O>,
    VisualElement {
  readonly skip: boolean;
}

declare const PointElement: ChartComponent & {
  prototype: PointElement;
  new (cfg: any): PointElement;
};

interface BarProps {
  x: number;
  y: number;
  base: number;
  horizontal: boolean;
  width: number;
  height: number;
}

interface BarOptions extends CommonOptions {
  /**
   * The base value for the bar in data units along the value axis.
   */
  base: number;

  /**
   * 	Skipped (excluded) border: 'start', 'end', 'bottom', 'left', 'top' or 'right'.
   * @default 'start'
   */
  borderSkipped: 'start' | 'end' | 'left' | 'right' | 'bottom' | 'top';

  /**
   * Border radius
   * @default 0
   */
  borderRadius: number | BorderRadius;
}

interface BorderRadius {
  topLeft: number;
  topRight: number;
  bottomLeft: number;
  bottomRight: number;
}

interface BarHoverOptions extends CommonHoverOptions {
  hoverBorderRadius: number | BorderRadius;
}

interface BarElement<
  T extends BarProps = BarProps,
  O extends BarOptions = BarOptions
> extends Element<T, O>, VisualElement {}

declare const BarElement: ChartComponent & {
  prototype: BarElement;
  new (cfg: any): BarElement;
};

interface ElementChartOptions {
  elements: {
    arc: ArcOptions & ArcHoverOptions;
    bar: BarOptions & BarHoverOptions;
    line: LineOptions & LineHoverOptions;
    point: PointOptions & PointHoverOptions;
  };
}

declare const Filler: Plugin;

interface FillerOptions {
  propagate: boolean;
}

type FillTarget = number | string | { value: number } | 'start' | 'end' | 'origin' | 'stack' | false;

interface ComplexFillTarget {
  /**
   * The accepted values are the same as the filling mode values, so you may use absolute and relative dataset indexes and/or boundaries.
   */
  target: FillTarget;
  /**
   * If no color is set, the default color will be the background color of the chart.
   */
  above: Color;
  /**
   * Same as the above.
   */
  below: Color;
}

interface FillerControllerDatasetOptions {
  /**
   * Both line and radar charts support a fill option on the dataset object which can be used to create area between two datasets or a dataset and a boundary, i.e. the scale origin, start or end
   */
  fill: FillTarget | ComplexFillTarget;
}

declare const Legend: Plugin;

interface LegendItem {
  /**
   * Label that will be displayed
   */
  text: string;

  /**
   * Fill style of the legend box
   */
  fillStyle: CanvasLineCap;

  /**
   * If true, this item represents a hidden dataset. Label will be rendered with a strike-through effect
   */
  hidden: boolean;

  /**
   * For box border.
   * @see https://developer.mozilla.org/en/docs/Web/API/CanvasRenderingContext2D/lineCap
   */
  lineCap: CanvasLineCap;

  /**
   * For box border.
   * @see https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/setLineDash
   */
  lineDash: number[];

  /**
   * For box border.
   * @see https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/lineDashOffset
   */
  lineDashOffset: number;

  /**
   * For box border.
   * @see https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/lineJoin
   */
  lineJoin: CanvasLineJoin;

  /**
   * Width of box border
   */
  lineWidth: number;

  /**
   * Stroke style of the legend box
   */
  strokeStyle: Color;

  /**
   * Point style of the legend box (only used if usePointStyle is true)
   */
  pointStyle: PointStyle;

  /**
   * Rotation of the point in degrees (only used if usePointStyle is true)
   */
  rotation: number;
}

interface LegendElement extends Element {}

interface LegendOptions {
  /**
   * Is the legend shown?
   * @default true
   */
  display: boolean;
  /**
   * Position of the legend.
   * @default 'top'
   */
  position: LayoutPosition;
  /**
   * Alignment of the legend.
   * @default 'center'
   */
  align: TextAlign;
  /**
   * Marks that this box should take the full width of the canvas (pushing down other boxes). This is unlikely to need to be changed in day-to-day use.
   * @default true
   */
  fullWidth: boolean;
  /**
   * Legend will show datasets in reverse order.
   * @default false
   */
  reverse: boolean;
  /**
   * A callback that is called when a click event is registered on a label item.
   */
  onClick(this: LegendElement, e: ChartEvent, legendItem: LegendItem, legend: LegendElement): void;
  /**
   *	A callback that is called when a 'mousemove' event is registered on top of a label item
   */
  onHover(this: LegendElement, e: ChartEvent, legendItem: LegendItem, legend: LegendElement): void;
  /**
   *	A callback that is called when a 'mousemove' event is registered outside of a previously hovered label item.
   */
  onLeave(this: LegendElement, e: ChartEvent, legendItem: LegendItem, legend: LegendElement): void;

  labels: {
    /**
     * Width of colored box.
     * @default 40
     */
    boxWidth: number;
    /**
     * Height of the coloured box.
     * @default fontSize
     */
    boxHeight: number;

    font: FontSpec;
    /**
     * Padding between rows of colored boxes.
     * @default 10
     */
    padding: number;
    /**
     * Generates legend items for each thing in the legend. Default implementation returns the text + styling for the color box. See Legend Item for details.
     */
    generateLabels(chart: Chart): LegendItem[];

    /**
     * Filters legend items out of the legend. Receives 2 parameters, a Legend Item and the chart data
     */
    filter(item: LegendItem, data: ChartData): boolean;

    /**
     * Sorts the legend items
     */
    sort(a: LegendItem, b: LegendItem, data: ChartData): number;

    /**
     * Override point style for the legend. Only applies if usePointStyle is true
     */
    pointStyle: PointStyle;

    /**
     * Label style will match corresponding point style (size is based on the mimimum value between boxWidth and font.size).
     * @default false
     */
    usePointStyle: boolean;
  };

  title: {
    /**
     * Is the legend title displayed.
     * @default false
     */
    display: boolean;
    /**
     * see Fonts
     */
    font: FontSpec;
    position: 'center' | 'start' | 'end';
    padding?: number | ChartArea;
    /**
     * The string title.
     */
    text: string;
  };
}

interface LegendChartOptions {
  legend: LegendOptions;
}

declare const Title: Plugin;

interface TitleOptions {
  /**
   * Alignment of the title.
   * @default 'center'
   */
  align: 'start' | 'center' | 'end';
  /**
   * Is the title shown?
   * @default false
   */
  display: boolean;
  /**
   * Position of title
   * @default 'top'
   */
  position: 'top' | 'left' | 'bottom' | 'right';
  font: FontSpec;
  // fullWidth: boolean;
  /**
   * 	Adds padding above and below the title text if a single number is specified. It is also possible to change top and bottom padding separately.
   */
  padding: number | { top: number; bottom: number };
  /**
   * 	Title text to display. If specified as an array, text is rendered on multiple lines.
   */
  text: string | string[];
}

interface TitleChartOptions {
  title: TitleOptions;
}

type TooltipAlignment = 'start' | 'center' | 'end';

interface TooltipModel {
  // The items that we are rendering in the tooltip. See Tooltip Item Interface section
  dataPoints: TooltipItem[];

  // Positioning
  xAlign: TooltipAlignment;
  yAlign: TooltipAlignment;

  // X and Y properties are the top left of the tooltip
  x: number;
  y: number;
  width: number;
  height: number;
  // Where the tooltip points to
  caretX: number;
  caretY: number;

  // Body
  // The body lines that need to be rendered
  // Each object contains 3 parameters
  // before: string[] // lines of text before the line with the color square
  // lines: string[]; // lines of text to render as the main item with color square
  // after: string[]; // lines of text to render after the main lines
  body: { before: string[]; lines: string[]; after: string[] }[];
  // lines of text that appear after the title but before the body
  beforeBody: string[];
  // line of text that appear after the body and before the footer
  afterBody: string[];

  // Title
  // lines of text that form the title
  title: string[];

  // Footer
  // lines of text that form the footer
  footer: string[];

  // colors to render for each item in body[]. This is the color of the squares in the tooltip
  labelColors: Color[];
  labelTextColors: Color[];
  labelPointStyles: { pointStyle: PointStyle; rotation: number }[];

  // 0 opacity is a hidden tooltip
  opacity: number;

  // tooltip options
  options: TooltipOptions;
}

declare const Tooltip: Plugin & {
  readonly positioners: {
    [key: string]: (items: readonly Element[], eventPosition: { x: number; y: number }) => { x: number; y: number };
  };

  getActiveElements(): ActiveElement[];
  setActiveElements(active: ActiveDataPoint[], eventPosition: { x: number, y: number }): void;
};

interface TooltipCallbacks {
  beforeTitle(this: TooltipModel, tooltipItems: TooltipItem[]): string | string[];
  title(this: TooltipModel, tooltipItems: TooltipItem[]): string | string[];
  afterTitle(this: TooltipModel, tooltipItems: TooltipItem[]): string | string[];

  beforeBody(this: TooltipModel, tooltipItems: TooltipItem[]): string | string[];
  afterBody(this: TooltipModel, tooltipItems: TooltipItem[]): string | string[];

  beforeLabel(this: TooltipModel, tooltipItem: TooltipItem): string | string[];
  label(this: TooltipModel, tooltipItem: TooltipItem): string | string[];
  afterLabel(this: TooltipModel, tooltipItem: TooltipItem): string | string[];

  labelColor(this: TooltipModel, tooltipItem: TooltipItem): { borderColor: Color; backgroundColor: Color };
  labelTextColor(this: TooltipModel, tooltipItem: TooltipItem): Color;
  labelPointStyle(this: TooltipModel, tooltipItem: TooltipItem): { pointStyle: PointStyle; rotation: number };

  beforeFooter(this: TooltipModel, tooltipItems: TooltipItem[]): string | string[];
  footer(this: TooltipModel, tooltipItems: TooltipItem[]): string | string[];
  afterFooter(this: TooltipModel, tooltipItems: TooltipItem[]): string | string[];
}

interface TooltipPlugin<O = {}> {
  /**
   * @desc Called before drawing the `tooltip`. If any plugin returns `false`,
   * the tooltip drawing is cancelled until another `render` is triggered.
   * @param {Chart} chart - The chart instance.
   * @param {object} args - The call arguments.
   * @param {Tooltip} args.tooltip - The tooltip.
   * @param {object} options - The plugin options.
   * @returns {boolean} `false` to cancel the chart tooltip drawing.
   */
  beforeTooltipDraw?(chart: Chart, args: { tooltip: TooltipModel }, options: O): boolean | void;
  /**
   * @desc Called after drawing the `tooltip`. Note that this hook will not
   * be called if the tooltip drawing has been previously cancelled.
   * @param {Chart} chart - The chart instance.
   * @param {object} args - The call arguments.
   * @param {Tooltip} args.tooltip - The tooltip.
   * @param {object} options - The plugin options.
   */
  afterTooltipDraw?(chart: Chart, args: { tooltip: TooltipModel }, options: O): void;
}

interface TooltipOptions extends CoreInteractionOptions {
  /**
   * Are on-canvas tooltips enabled?
   * @default true
   */
  enabled: boolean;
  /**
   * 	See custom tooltip section.
   */
  custom(this: TooltipModel, args: { chart: Chart; tooltip: TooltipModel }): void;
  /**
   * The mode for positioning the tooltip
   */
  position: 'average' | 'nearest';

  /**
   * Override the tooltip alignment calculations
   */
  xAlign: TooltipAlignment;
  yAlign: TooltipAlignment;

  /**
   * Sort tooltip items.
   */
  itemSort: (a: TooltipItem, b: TooltipItem) => number;

  filter: (e: TooltipItem) => boolean;

  /**
   * Background color of the tooltip.
   * @default 'rgba(0, 0, 0, 0.8)'
   */
  backgroundColor: Color;
  /**
   * See Fonts
   * @default {style: 'bold', color: '#fff'}
   */
  titleFont: FontSpec;
  /**
   * Spacing to add to top and bottom of each title line.
   * @default 2
   */
  titleSpacing: number;
  /**
   * Margin to add on bottom of title section.
   * @default 6
   */
  titleMarginBottom: number;
  /**
   * Horizontal alignment of the title text lines.
   * @default 'left'
   */
  titleAlign: TextAlign;
  /**
   * Spacing to add to top and bottom of each tooltip item.
   * @default 2
   */
  bodySpacing: number;
  /**
   * 	See Fonts.
   * @default {color: '#fff'}
   */
  bodyFont: FontSpec;
  /**
   * Horizontal alignment of the body text lines.
   * @default 'left'
   */
  bodyAlign: TextAlign;
  /**
   * Spacing to add to top and bottom of each footer line.
   * @default 2
   */
  footerSpacing: number;
  /**
   * Margin to add before drawing the footer.
   * @default 6
   */
  footerMarginTop: number;
  /**
   * See Fonts
   * @default {style: 'bold', color: '#fff'}
   */
  footerFont: FontSpec;
  /**
   * Horizontal alignment of the footer text lines.
   * @default 'left'
   */
  footerAlign: TextAlign;
  /**
   * Padding to add on left and right of tooltip.
   * @default 6
   */
  xPadding: number;
  /**
   * Padding to add on top and bottom of tooltip.
   * @default 6
   */
  yPadding: number;
  /**
   * 	Extra distance to move the end of the tooltip arrow away from the tooltip point.
   * @default 2
   */
  caretPadding: number;
  /**
   * Size, in px, of the tooltip arrow.
   * @default 5
   */
  caretSize: number;
  /**
   * Radius of tooltip corner curves.
   * @default 6
   */
  cornerRadius: number;
  /**
   * Color to draw behind the colored boxes when multiple items are in the tooltip.
   * @default '#fff'
   */
  multiKeyBackground: Color;
  /**
   * If true, color boxes are shown in the tooltip.
   * @default true
   */
  displayColors: boolean;
  /**
   * Width of the color box if displayColors is true.
   * @default bodyFont.size
   */
  boxWidth: number;
  /**
   * Height of the color box if displayColors is true.
   * @default bodyFont.size
   */
  boxHeight: number;
  /**
   * Use the corresponding point style (from dataset options) instead of color boxes, ex: star, triangle etc. (size is based on the minimum value between boxWidth and boxHeight)
   * @default false
   */
  usePointStyle: boolean;
  /**
   * Color of the border.
   * @default 'rgba(0, 0, 0, 0)'
   */
  borderColor: Color;
  /**
   * Size of the border.
   * @default 0
   */
  borderWidth: number;
  /**
   * true for rendering the legends from right to left.
   */
  rtl: boolean;

  /**
   * This will force the text direction 'rtl' or 'ltr on the canvas for rendering the tooltips, regardless of the css specified on the canvas
   * @default canvas's default
   */
  textDirection: string;

  animation: Scriptable<AnimationSpecContainer>;

  callbacks: TooltipCallbacks;
}

interface TooltipChartOptions {
  tooltips: TooltipOptions;
}

interface TooltipItem {
  /**
   * The chart the tooltip is being shown on
   */
  chart: Chart;

  /**
   * Label for the tooltip
   */
  label: string;

  /**
   * Parsed data values for the given `dataIndex` and `datasetIndex`
   */
  dataPoint: any;

  /**
   * Formatted value for the tooltip
   */
  formattedValue: string;

  /**
   * The dataset the item comes from
   */
  dataset: ChartDataset;

  /**
   * Index of the dataset the item comes from
   */
  datasetIndex: number;

  /**
   * Index of this data item in the dataset
   */
  dataIndex: number;

  /**
   * The chart element (point, arc, bar, etc.) for this tooltip item
   */
  element: Element;
}

interface PluginOptions {
  filler: FillerOptions;
  legend: LegendOptions;
  title: TitleOptions;
  tooltip: TooltipOptions;
}

interface PluginChartOptions extends LegendChartOptions, TitleChartOptions, TooltipChartOptions {
}

interface GridLineOptions {
  /**
   * @default true
   */
  display: boolean;
  borderColor: Color;
  borderWidth: number;
  /**
   * @default false
   */
  circular: boolean;
  /**
   * @default 'rgba(0, 0, 0, 0.1)'
   */
  color: ScriptAbleScale<Color> | readonly Color[];
  /**
   * @default []
   */
  borderDash: number[];
  /**
   * @default 0
   */
  borderDashOffset: ScriptAbleScale<number>;
  /**
   * @default 1
   */
  lineWidth: ScriptAbleScale<number> | readonly number[];

  /**
   * @default true
   */
  drawBorder: boolean;
  /**
   * @default true
   */
  drawOnChartArea: boolean;
  /**
   * @default true
   */
  drawTicks: boolean;
  /**
   * @default 10
   */
  tickMarkLength: number;
  /**
   * @default false
   */
  offsetGridLines: boolean;
}

interface TickOptions {
  /**
   * Returns the string representation of the tick value as it should be displayed on the chart. See callback.
   */
  callback: (tickValue: any, index: number, ticks: Tick[]) => string;
  /**
   * If true, show tick labels.
   * @default true
   */
  display: boolean;
  /**
   * see Fonts
   */
  font: ScriptAbleScale<FontSpec>;
  /**
   * Sets the offset of the tick labels from the axis
   */
  padding: number;
  /**
   * z-index of tick layer. Useful when ticks are drawn on chart area. Values <= 0 are drawn under datasets, > 0 on top.
   * @default 0
   */
  z: number;

  major: {
    /**
     * If true, major ticks are generated. A major tick will affect autoskipping and major will be defined on ticks in the scriptable options context.
     * @default false
     */
    enabled: boolean;
  };
}

interface CartesianScaleOptions extends CoreScaleOptions {
  /**
   * Position of the axis.
   */
  position: 'left' | 'top' | 'right' | 'bottom' | 'center' | { [scale: string]: number };
  /**
   * 	Which type of axis this is. Possible values are: 'x', 'y'. If not set, this is inferred from the first character of the ID which should be 'x' or 'y'.
   */
  axis: 'x' | 'y';

  /**
   * User defined minimum value for the scale, overrides minimum value from data.
   */
  min: number;

  /**
   * User defined maximum value for the scale, overrides maximum value from data.
   */
  max: number;

  /**
   * 	If true, extra space is added to the both edges and the axis is scaled to fit into the chart area. This is set to true for a bar chart by default.
   * @default false
   */
  offset: boolean;

  gridLines: GridLineOptions;

  scaleLabel: {
    display: boolean;
    labelString: string;
    font: FontSpec;
    padding: {
      top: number;
      bottom: number;
    };
  };

	/**
	 * 	If true, data will be comprised between datasets of data
	 * @default false
	 */
  stacked?: boolean;

  ticks: TickOptions & {
    /**
     * The number of ticks to examine when deciding how many labels will fit. Setting a smaller value will be faster, but may be less accurate when there is large variability in label length.
     * @default ticks.length
     */
    sampleSize: number;
    /**
     * The label alignment
     * @default 'center'
     */
    align: 'start' | 'center' | 'end';
    /**
     * 	If true, automatically calculates how many labels can be shown and hides labels accordingly. Labels will be rotated up to maxRotation before skipping any. Turn autoSkip off to show all labels no matter what.
     * @default true
     */
    autoSkip: boolean;
    /**
     * Padding between the ticks on the horizontal axis when autoSkip is enabled.
     * @default 0
     */
    autoSkipPadding: number;

    /**
     * How is the label positioned perpendicular to the axis direction.
     * This only applies when the rotation is 0 and the axis position is one of "top", "left", "right", or "bottom"
     * @default 'near'
     */
    crossAlign: 'near' | 'center' | 'far';

    /**
     * Distance in pixels to offset the label from the centre point of the tick (in the x direction for the x axis, and the y direction for the y axis). Note: this can cause labels at the edges to be cropped by the edge of the canvas
     * @default 0
     */
    labelOffset: number;

    /**
     * Minimum rotation for tick labels. Note: Only applicable to horizontal scales.
     * @default 0
     */
    minRotation: number;
    /**
     * Maximum rotation for tick labels when rotating to condense labels. Note: Rotation doesn't occur until necessary. Note: Only applicable to horizontal scales.
     * @default 50
     */
    maxRotation: number;
    /**
     * Flips tick labels around axis, displaying the labels inside the chart instead of outside. Note: Only applicable to vertical scales.
     * @default false
     */
    mirror: boolean;
    /**
     * 	Padding between the tick label and the axis. When set on a vertical axis, this applies in the horizontal (X) direction. When set on a horizontal axis, this applies in the vertical (Y) direction.
     * @default 0
     */
    padding: number;
  };
}

type CategoryScaleOptions = CartesianScaleOptions & {
  min: string | number;
  max: string | number;
  labels: string[] | string[][];
};

interface CategoryScale<O extends CategoryScaleOptions = CategoryScaleOptions> extends Scale<O> {}
declare const CategoryScale: ChartComponent & {
  prototype: CategoryScale;
  new <O extends CategoryScaleOptions = CategoryScaleOptions>(cfg: any): CategoryScale<O>;
};

type LinearScaleOptions = CartesianScaleOptions & {

  /**
   *	if true, scale will include 0 if it is not already included.
   * @default true
   */
  beginAtZero: boolean;

  /**
   * Adjustment used when calculating the maximum data value.
   * @see https://www.chartjs.org/docs/next/axes/cartesian/linear#axis-range-settings
   */
  suggestedMin?: number;
  /**
   * Adjustment used when calculating the minimum data value.
   * @see https://www.chartjs.org/docs/next/axes/cartesian/linear#axis-range-settings
   */
  suggestedMax?: number;

  ticks: {
    /**
     * The Intl.NumberFormat options used by the default label formatter
     */
    format: Intl.NumberFormatOptions;

    /**
     * Maximum number of ticks and gridlines to show.
     * @default 11
     */
    maxTicksLimit: number;
    /**
     * if defined and stepSize is not specified, the step size will be rounded to this many decimal places.
     */
    precision: number;

    /**
     * User defined fixed step size for the scale
     * @see https://www.chartjs.org/docs/next/axes/cartesian/linear#step-size
     */
    stepSize: number;
  };
};

interface LinearScale<O extends LinearScaleOptions = LinearScaleOptions> extends Scale<O> {}
declare const LinearScale: ChartComponent & {
  prototype: LinearScale;
  new <O extends LinearScaleOptions = LinearScaleOptions>(cfg: any): LinearScale<O>;
};

type LogarithmicScaleOptions = CartesianScaleOptions & {

  /**
   * Adjustment used when calculating the maximum data value.
   * @see https://www.chartjs.org/docs/next/axes/cartesian/linear#axis-range-settings
   */
  suggestedMin?: number;
  /**
   * Adjustment used when calculating the minimum data value.
   * @see https://www.chartjs.org/docs/next/axes/cartesian/linear#axis-range-settings
   */
  suggestedMax?: number;

  ticks: {
    /**
     * The Intl.NumberFormat options used by the default label formatter
     */
    format: Intl.NumberFormatOptions;
  };
};

interface LogarithmicScale<O extends LogarithmicScaleOptions = LogarithmicScaleOptions> extends Scale<O> {}
declare const LogarithmicScale: ChartComponent & {
  prototype: LogarithmicScale;
  new <O extends LogarithmicScaleOptions = LogarithmicScaleOptions>(cfg: any): LogarithmicScale<O>;
};

type TimeScaleOptions = CartesianScaleOptions & {
  /**
   * Scale boundary strategy (bypassed by min/max time options)
   * - `data`: make sure data are fully visible, ticks outside are removed
   * - `ticks`: make sure ticks are fully visible, data outside are truncated
   * @see https://www.chartjs.org/docs/next/axes/cartesian/time#scale-bounds
   * @since 2.7.0
   * @default 'data'
   */
  bounds: 'ticks' | 'data';

  /**
   * options for creating a new adapter instance
   */
  adapters: {
    date: any;
  };

  time: {
    /**
     * Custom parser for dates.
     * @see https://www.chartjs.org/docs/next/axes/cartesian/time#parser
     */
    parser: string | ((v: any) => number);
    /**
     * If defined, dates will be rounded to the start of this unit. See Time Units below for the allowed units.
     */
    round: false | TimeUnit;
    /**
     * If boolean and true and the unit is set to 'week', then the first day of the week will be Monday. Otherwise, it will be Sunday.
     * If `number`, the index of the first day of the week (0 - Sunday, 6 - Saturday).
     * @default false
     */
    isoWeekday: false | number;
    /**
     * Sets how different time units are displayed.
     * @see https://www.chartjs.org/docs/next/axes/cartesian/time#display-formats
     */
    displayFormats: {
      [key: string]: string;
    };
    /**
     * The format string to use for the tooltip.
     */
    tooltipFormat: string;
    /**
     * If defined, will force the unit to be a certain type. See Time Units section below for details.
     * @default false
     */
    unit: false | TimeUnit;

    /**
     * The number of units between grid lines.
     * @default 1
     */
    stepSize: number;
    /**
     * The minimum display format to be used for a time unit.
     * @default 'millisecond'
     */
    minUnit: TimeUnit;
  };

  ticks: {
    /**
     * Ticks generation input values:
     * - 'auto': generates "optimal" ticks based on scale size and time options.
     * - 'data': generates ticks from data (including labels from data {t|x|y} objects).
     * - 'labels': generates ticks from user given `data.labels` values ONLY.
     * @see https://github.com/chartjs/Chart.js/pull/4507
     * @since 2.7.0
     * @default 'auto'
     * @see https://www.chartjs.org/docs/next/axes/cartesian/time#ticks-source
     */
    source: 'labels' | 'auto' | 'data';
  };
};

interface TimeScale<O extends TimeScaleOptions = TimeScaleOptions> extends Scale<O> {
  getDataTimestamps(): number[];
  getLabelTimestamps(): string[];
  normalize(values: number[]): number[];
}

declare const TimeScale: ChartComponent & {
  prototype: TimeScale;
  new <O extends TimeScaleOptions = TimeScaleOptions>(cfg: any): TimeScale<O>;
};

interface TimeSeriesScale<O extends TimeScaleOptions = TimeScaleOptions> extends TimeScale<O> {}
declare const TimeSeriesScale: ChartComponent & {
  prototype: TimeSeriesScale;
  new <O extends TimeScaleOptions = TimeScaleOptions>(cfg: any): TimeSeriesScale<O>;
};

type RadialLinearScaleOptions = CoreScaleOptions & {
  animate: boolean;

  angleLines: {
    /**
     * if true, angle lines are shown.
     * @default true
     */
    display: boolean;
    /**
     * Color of angled lines.
     * @default 'rgba(0, 0, 0, 0.1)'
     */
    color: ScriptAbleScale<Color>;
    /**
     * Width of angled lines.
     * @default 1
     */
    lineWidth: ScriptAbleScale<number>;
    /**
     * Length and spacing of dashes on angled lines. See MDN.
     * @default []
     */
    borderDash: ScriptAbleScale<number[]>;
    /**
     * Offset for line dashes. See MDN.
     * @default 0
     */
    borderDashOffset: ScriptAbleScale<number>;
  };

  /**
   * if true, scale will include 0 if it is not already included.
   * @default false
   */
  beginAtZero: boolean;

  gridLines: GridLineOptions;

  /**
   * User defined minimum number for the scale, overrides minimum value from data.
   */
  min: number;
  /**
   * User defined maximum number for the scale, overrides maximum value from data.
   */
  max: number;

  pointLabels: {
    /**
     * if true, point labels are shown.
     * @default true
     */
    display: boolean;
    /**
     * @see https://www.chartjs.org/docs/next/axes/general/fonts.md
     */
    font: ScriptAbleScale<FontSpec>;

    /**
     * Callback function to transform data labels to point labels. The default implementation simply returns the current string.
     * @default true
     */
    callback: (label: string) => string;
  };

  /**
   * Adjustment used when calculating the maximum data value.
   */
  suggestedMax: number;
  /**
   * Adjustment used when calculating the minimum data value.
   */
  suggestedMin: number;

  ticks: TickOptions & {
    /**
     * Color of label backdrops.
     * @default 'rgba(255, 255, 255, 0.75)'
     */
    backdropColor: ScriptAbleScale<Color>;
    /**
     * Horizontal padding of label backdrop.
     * @default 2
     */
    backdropPaddingX: number;
    /**
     * Vertical padding of label backdrop.
     * @default 2
     */
    backdropPaddingY: number;

    /**
     * The Intl.NumberFormat options used by the default label formatter
     */
    format: Intl.NumberFormatOptions;

    /**
     * Maximum number of ticks and gridlines to show.
     * @default 11
     */
    maxTicksLimit: number;

    /**
     * if defined and stepSize is not specified, the step size will be rounded to this many decimal places.
     */
    precision: number;

    /**
     * User defined fixed step size for the scale.
     */
    stepSize: number;

    /**
     * If true, draw a background behind the tick labels.
     * @default true
     */
    showLabelBackdrop: ScriptAbleScale<boolean>;
  };
};

interface RadialLinearScale<O extends RadialLinearScaleOptions = RadialLinearScaleOptions> extends Scale<O> {
  setCenterPoint(leftMovement: number, rightMovement: number, topMovement: number, bottomMovement: number): void;
  getIndexAngle(index: number): number;
  getDistanceFromCenterForValue(value: number): number;
  getValueForDistanceFromCenter(distance: number): number;
  getPointPosition(index: number, distanceFromCenter: number): { x: number; y: number; angle: number };
  getPointPositionForValue(index: number, value: number): { x: number; y: number; angle: number };
  getBasePosition(index: number): { x: number; y: number; angle: number };
}
declare const RadialLinearScale: ChartComponent & {
  prototype: RadialLinearScale;
  new <O extends RadialLinearScaleOptions = RadialLinearScaleOptions>(cfg: any): RadialLinearScale<O>;
};

type DeepPartial<T> = T extends {}
  ? {
      [K in keyof T]?: DeepPartial<T[K]>;
    }
  : T;

type DistributiveArray<T> = T extends unknown ? T[] : never

interface CartesianScaleTypeRegistry {
  linear: {
    options: LinearScaleOptions;
  };
  logarithmic: {
    options: LogarithmicScaleOptions;
  };
  category: {
    options: CategoryScaleOptions;
  };
  time: {
    options: TimeScaleOptions;
  };
  timeseries: {
    options: TimeScaleOptions;
  };
}

interface RadialScaleTypeRegistry {
  radialLinear: {
    options: RadialLinearScaleOptions;
  };
}

interface ScaleTypeRegistry extends CartesianScaleTypeRegistry, RadialScaleTypeRegistry {
}

type ScaleType = keyof ScaleTypeRegistry;

interface ChartTypeRegistry {
  bar: {
    chartOptions: BarControllerChartOptions;
    datasetOptions: BarControllerDatasetOptions;
    defaultDataPoint: number;
    scales: keyof CartesianScaleTypeRegistry;
  };
  line: {
    chartOptions: LineControllerChartOptions;
    datasetOptions: LineControllerDatasetOptions & FillerControllerDatasetOptions;
    defaultDataPoint: ScatterDataPoint;
    scales: keyof CartesianScaleTypeRegistry;
  };
  scatter: {
    chartOptions: ScatterControllerChartOptions;
    datasetOptions: ScatterControllerDatasetOptions;
    defaultDataPoint: ScatterDataPoint;
    scales: keyof CartesianScaleTypeRegistry;
  };
  bubble: {
    chartOptions: {};
    datasetOptions: BubbleControllerDatasetOptions;
    defaultDataPoint: BubbleDataPoint;
    scales: keyof CartesianScaleTypeRegistry;
  };
  pie: {
    chartOptions: PieControllerChartOptions;
    datasetOptions: PieControllerDatasetOptions;
    defaultDataPoint: PieDataPoint;
    scales: keyof CartesianScaleTypeRegistry;
  };
  doughnut: {
    chartOptions: DoughnutControllerChartOptions;
    datasetOptions: DoughnutControllerDatasetOptions;
    defaultDataPoint: DoughnutDataPoint;
    scales: keyof CartesianScaleTypeRegistry;
  };
  polarArea: {
    chartOptions: PolarAreaControllerChartOptions;
    datasetOptions: PolarAreaControllerDatasetOptions;
    defaultDataPoint: number;
    scales: keyof RadialScaleTypeRegistry;
  };
  radar: {
    chartOptions: RadarControllerChartOptions;
    datasetOptions: RadarControllerDatasetOptions;
    defaultDataPoint: number;
    scales: keyof RadialScaleTypeRegistry;
  };
}

type ChartType = keyof ChartTypeRegistry;

type ScaleOptions<TScale extends ScaleType = ScaleType> = DeepPartial<
  { [key in ScaleType]: { type: key } & ScaleTypeRegistry[key]['options'] }[TScale]
>;

type DatasetChartOptions<TType extends ChartType = ChartType> = {
  [key in TType]: {
    datasets: ChartTypeRegistry[key]['datasetOptions'];
  };
};

type ScaleChartOptions<TType extends ChartType = ChartType> = {
  scales: {
    [key: string]: ScaleOptions<ChartTypeRegistry[TType]['scales']>;
  };
};

type ChartOptions<TType extends ChartType = ChartType> = DeepPartial<
  CoreChartOptions &
  PluginChartOptions &
  ElementChartOptions &
  DatasetChartOptions<TType> &
  ScaleChartOptions<TType> &
  ChartTypeRegistry[TType]['chartOptions']
>;

type DefaultDataPoint<TType extends ChartType> = ChartType extends TType ? unknown[] : DistributiveArray<
  ChartTypeRegistry[TType]['defaultDataPoint']
>;

interface ChartDatasetProperties<TType extends ChartType, TData extends unknown[]> {
  type?: TType;
  data: TData;
}

type ChartDataset<
  TType extends ChartType = ChartType,
  TData extends unknown[] = DefaultDataPoint<TType>
> = DeepPartial<
  { [key in ChartType]: { type: key } & ChartTypeRegistry[key]['datasetOptions'] }[TType]
> & ChartDatasetProperties<TType, TData>;

interface ChartData<
  TType extends ChartType = ChartType,
  TData extends unknown[] = DefaultDataPoint<TType>,
  TLabel = unknown
> {
  labels: TLabel[];
  datasets: ChartDataset<TType, TData>[];
}

interface ChartConfiguration<
  TType extends ChartType = ChartType,
  TData extends unknown[] = DefaultDataPoint<TType>,
  TLabel = unknown
> {
  type: TType;
  data: ChartData<TType, TData, TLabel>;
  options?: ChartOptions<TType>;
  plugins?: Plugin[];
}

type Color = string | CanvasGradient | CanvasPattern;

interface ChartEvent {
  type:
    | 'contextmenu'
    | 'mouseenter'
    | 'mousedown'
    | 'mousemove'
    | 'mouseup'
    | 'mouseout'
    | 'click'
    | 'dblclick'
    | 'keydown'
    | 'keypress'
    | 'keyup'
    | 'resize';
  native: Event | null;
  x: number | null;
  y: number | null;
}

interface Point {
  x: number;
  y: number;
}

interface ChartComponent {
  id: string;
  defaults?: any;
  defaultRoutes?: { [property: string]: string };

  beforeRegister?(): void;
  afterRegister?(): void;
  beforeUnregister?(): void;
  afterUnregister?(): void;
}

type TimeUnit = 'millisecond' | 'second' | 'minute' | 'hour' | 'day' | 'week' | 'month' | 'quarter' | 'year';

interface ChartArea {
  top: number;
  left: number;
  right: number;
  bottom: number;
}

interface ScriptableContext {
  chart: Chart;
  dataPoint: any;
  dataIndex: number;
  dataset: ChartDataset;
  datasetIndex: number;
  active: boolean;
}

type Scriptable<T> = T | ((ctx: ScriptableContext) => T);
type ScriptableOptions<T> = { [P in keyof T]: Scriptable<T[P]> };
type ScriptableAndArray<T> = readonly T[] | Scriptable<T>;
type ScriptableAndArrayOptions<T> = { [P in keyof T]: ScriptableAndArray<T[P]> };

interface CoreInteractionOptions {
  /**
   * Sets which elements appear in the tooltip. See Interaction Modes for details.
   * @default 'nearest'
   */
  mode: InteractionMode;
  /**
   * if true, the hover mode only applies when the mouse position intersects an item on the chart.
   * @default true
   */
  intersect: boolean;

  /**
   * Can be set to 'x', 'y', or 'xy' to define which directions are used in calculating distances. Defaults to 'x' for 'index' mode and 'xy' in dataset and 'nearest' modes.
   */
  axis: 'x' | 'y' | 'xy';
}

interface HoverInteractionOptions extends CoreInteractionOptions {
  /**
   * Called when any of the events fire. Passed the event, an array of active elements (bars, points, etc), and the chart.
   */
  onHover(event: ChartEvent, elements: Element[]): void;
}

interface CoreChartOptions extends ParsingOptions {
  animation: Scriptable<AnimationOptions>;

  datasets: {
    animation: Scriptable<AnimationOptions>;
  };

  /**
   * base color
   * @see Defaults.color
   */
  color: string;
  /**
   * base font
   * @see Defaults.font
   */
  font: FontSpec;
  /**
   * Resizes the chart canvas when its container does (important note...).
   * @default true
   */
  responsive: boolean;
  /**
   * Maintain the original canvas aspect ratio (width / height) when resizing.
   * @default true
   */
  maintainAspectRatio: boolean;

  /**
   * Canvas aspect ratio (i.e. width / height, a value of 1 representing a square canvas). Note that this option is ignored if the height is explicitly defined either as attribute or via the style.
   * @default 2
   */
  aspectRatio: number;

  /**
   * Called when a resize occurs. Gets passed two arguments: the chart instance and the new size.
   */
  onResize(chart: Chart, size: { width: number; height: number }): void;

  /**
   * Override the window's default devicePixelRatio.
   * @default window.devicePixelRatio
   */
  devicePixelRatio: number;

  interaction: CoreInteractionOptions;

  hover: HoverInteractionOptions;

  /**
   * The events option defines the browser events that the chart should listen to for tooltips and hovering.
   * @default ['mousemove', 'mouseout', 'click', 'touchstart', 'touchmove']
   */
  events: ('mousemove' | 'mouseout' | 'click' | 'touchstart' | 'touchmove')[];

  /**
   * Called when any of the events fire. Passed the event, an array of active elements (bars, points, etc), and the chart.
   */
  onHover(event: ChartEvent, elements: Element[]): void;

  /**
   * Called if the event is of type 'mouseup' or 'click'. Passed the event, an array of active elements, and the chart.
   */
  onClick(event: ChartEvent, elements: Element[]): void;

  layout: {
    padding: Scriptable<number | ChartArea>;
  };

  plugins: PluginOptions;
}

type EasingFunction =
  | 'linear'
  | 'easeInQuad'
  | 'easeOutQuad'
  | 'easeInOutQuad'
  | 'easeInCubic'
  | 'easeOutCubic'
  | 'easeInOutCubic'
  | 'easeInQuart'
  | 'easeOutQuart'
  | 'easeInOutQuart'
  | 'easeInQuint'
  | 'easeOutQuint'
  | 'easeInOutQuint'
  | 'easeInSine'
  | 'easeOutSine'
  | 'easeInOutSine'
  | 'easeInExpo'
  | 'easeOutExpo'
  | 'easeInOutExpo'
  | 'easeInCirc'
  | 'easeOutCirc'
  | 'easeInOutCirc'
  | 'easeInElastic'
  | 'easeOutElastic'
  | 'easeInOutElastic'
  | 'easeInBack'
  | 'easeOutBack'
  | 'easeInOutBack'
  | 'easeInBounce'
  | 'easeOutBounce'
  | 'easeInOutBounce';

interface AnimationCommonSpec {
	/**
	 * The number of milliseconds an animation takes.
	 * @default 1000
	 */
	duration: number;
	/**
	 * Easing function to use
	 * @default 'easeOutQuart'
	 */
	easing: EasingFunction;

	/**
	 * Running animation count + FPS display in upper left corner of the chart.
	 * @default false
	 */
	debug: boolean;

	/**
	 * Delay before starting the animations.
	 * @default 0
	 */
	delay: number;

	/**
	 * 	If set to true, the animations loop endlessly.
	 * @default false
	 */
	loop: boolean;
}

interface AnimationPropertySpec extends AnimationCommonSpec {
	properties: string[];

	/**
	 * Type of property, determines the interpolator used. Possible values: 'number', 'color' and 'boolean'. Only really needed for 'color', because typeof does not get that right.
	 */
	type: 'color' | 'number' | 'boolean';

	fn: <T>(from: T, to: T, factor: number) => T;

	/**
	 * Start value for the animation. Current value is used when undefined
	 */
	from: Color | number | boolean;
	/**
	 *
	 */
	to: Color | number | boolean;
}

type AnimationSpecContainer = AnimationCommonSpec & {
	[prop: string]: AnimationPropertySpec;
};

type AnimationOptions = AnimationSpecContainer & {
	/**
	 * Callback called on each step of an animation.
	 */
	onProgress: (this: Chart, event: AnimationEvent) => void;
	/**
	 *Callback called when all animations are completed.
	 */
	onComplete: (this: Chart, event: AnimationEvent) => void;

	active: AnimationSpecContainer;
	hide: AnimationSpecContainer;
	reset: AnimationSpecContainer;
	resize: AnimationSpecContainer;
	show: AnimationSpecContainer;
};

interface FontSpec {
  /**
   * Default font color for all text.
   * @default '#666'
   */
  color: Color;
  /**
   * Default font family for all text, follows CSS font-family options.
   * @default "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif"
   */
  family: string;
  /**
   * Default font size (in px) for text. Does not apply to radialLinear scale point labels.
   * @default 12
   */
  size: number;
  /**
   * Default font style. Does not apply to tooltip title or footer. Does not apply to chart title. Follows CSS font-style options (i.e. normal, italic, oblique, initial, inherit)
   * @default 'normal'
   */
  style: 'normal' | 'italic' | 'oblique' | 'initial' | 'inherit';
  /**
   * Default font weight (boldness). (see MDN).
   */
  weight: string | null;
  /**
   * Height of an individual line of text (see MDN).
   * @default 1.2
   */
  lineHeight: number | string;
  /**
   * Stroke width around the text. Currently only supported by ticks.
   * @default 0
   */
  lineWidth: number;
  /**
   * The color of the stroke around the text. Currently only supported by ticks.
   */
  strokeStyle: string | null;
}

type TextAlign = 'left' | 'center' | 'right';

declare class BasePlatform {
  /**
   * Called at chart construction time, returns a context2d instance implementing
   * the [W3C Canvas 2D Context API standard]{@link https://www.w3.org/TR/2dcontext/}.
   * @param {HTMLCanvasElement} canvas - The canvas from which to acquire context (platform specific)
   * @param options - The chart options
   */
  acquireContext(
    canvas: HTMLCanvasElement,
    options?: CanvasRenderingContext2DSettings
  ): CanvasRenderingContext2D | null;
  /**
   * Called at chart destruction time, releases any resources associated to the context
   * previously returned by the acquireContext() method.
   * @param {CanvasRenderingContext2D} context - The context2d instance
   * @returns {boolean} true if the method succeeded, else false
   */
  releaseContext(context: CanvasRenderingContext2D): boolean;
  /**
   * Registers the specified listener on the given chart.
   * @param {Chart} chart - Chart from which to listen for event
   * @param {string} type - The ({@link ChartEvent}) type to listen for
   * @param listener - Receives a notification (an object that implements
   * the {@link ChartEvent} interface) when an event of the specified type occurs.
   */
  addEventListener(chart: Chart, type: string, listener: (e: ChartEvent) => void): void;
  /**
   * Removes the specified listener previously registered with addEventListener.
   * @param {Chart} chart - Chart from which to remove the listener
   * @param {string} type - The ({@link ChartEvent}) type to remove
   * @param listener - The listener function to remove from the event target.
   */
  removeEventListener(chart: Chart, type: string, listener: (e: ChartEvent) => void): void;
  /**
   * @returns {number} the current devicePixelRatio of the device this platform is connected to.
   */
  getDevicePixelRatio(): number;
  /**
   * @param {HTMLCanvasElement} canvas - The canvas for which to calculate the maximum size
   * @param {number} [width] - Parent element's content width
   * @param {number} [height] - Parent element's content height
   * @param {number} [aspectRatio] - The aspect ratio to maintain
   * @returns { width: number, height: number } the maximum size available.
   */
  getMaximumSize(canvas: HTMLCanvasElement, width?: number, height?: number, aspectRatio?: number): { width: number, height: number };
  /**
   * @param {HTMLCanvasElement} canvas
   * @returns {boolean} true if the canvas is attached to the platform, false if not.
   */
  isAttached(canvas: HTMLCanvasElement): boolean;
}

declare class BasicPlatform extends BasePlatform {}
declare class DomPlatform extends BasePlatform {}

interface DateAdapterBase {
	/**
	 * Returns a map of time formats for the supported formatting units defined
	 * in Unit as well as 'datetime' representing a detailed date/time string.
	 * @returns {{string: string}}
	 */
	formats(): { [key: string]: string };
	/**
	 * Parses the given `value` and return the associated timestamp.
	 * @param {any} value - the value to parse (usually comes from the data)
	 * @param {string} [format] - the expected data format
	 */
	parse(value: any, format?: TimeUnit): number | null;
	/**
	 * Returns the formatted date in the specified `format` for a given `timestamp`.
	 * @param {number} timestamp - the timestamp to format
	 * @param {string} format - the date/time token
	 * @return {string}
	 */
	format(timestamp: number, format: TimeUnit): string;
	/**
	 * Adds the specified `amount` of `unit` to the given `timestamp`.
	 * @param {number} timestamp - the input timestamp
	 * @param {number} amount - the amount to add
	 * @param {Unit} unit - the unit as string
	 * @return {number}
	 */
	add(timestamp: number, amount: number, unit: TimeUnit): number;
	/**
	 * Returns the number of `unit` between the given timestamps.
	 * @param {number} a - the input timestamp (reference)
	 * @param {number} b - the timestamp to subtract
	 * @param {Unit} unit - the unit as string
	 * @return {number}
	 */
	diff(a: number, b: number, unit: TimeUnit): number;
	/**
	 * Returns start of `unit` for the given `timestamp`.
	 * @param {number} timestamp - the input timestamp
	 * @param {Unit|'isoWeek'} unit - the unit as string
	 * @param {number} [weekday] - the ISO day of the week with 1 being Monday
	 * and 7 being Sunday (only needed if param *unit* is `isoWeek`).
	 * @return {number}
	 */
	startOf(timestamp: number, unit: TimeUnit | 'isoWeek', weekday?: number): number;
	/**
	 * Returns end of `unit` for the given `timestamp`.
	 * @param {number} timestamp - the input timestamp
	 * @param {Unit|'isoWeek'} unit - the unit as string
	 * @return {number}
	 */
	endOf(timestamp: number, unit: TimeUnit | 'isoWeek'): number;
}

interface DateAdapter extends DateAdapterBase {
	readonly options: any;
}

declare const DateAdapter: {
	prototype: DateAdapter;
	new(options: any): DateAdapter;
	override(members: Partial<DateAdapter>): void;
};

declare const _adapters: {
	_date: DateAdapter;
};

declare class Animation {
	constructor(cfg: any, target: any, prop: string, to?: any);
	active(): boolean;
	update(cfg: any, to: any, date: number): void;
	cancel(): void;
	tick(date: number): void;
}

interface AnimationEvent$1 {
	chart: Chart;
	numSteps: number;
	currentState: number;
}

declare class Animator {
	listen(chart: Chart, event: 'complete' | 'progress', cb: (event: AnimationEvent$1) => void): void;
	add(chart: Chart, items: readonly Animation[]): void;
	has(chart: Chart): boolean;
	start(chart: Chart): void;
	running(chart: Chart): boolean;
	stop(chart: Chart): void;
	remove(chart: Chart): boolean;
}

declare class Animations {
	constructor(chart: Chart, animations: {});
	configure(animations: {}): void;
	update(target: any, values: any): undefined | boolean;
}

interface ChartMeta<TElement extends Element = Element, TDatasetElement extends Element = Element> {
	type: string;
	controller: DatasetController;
	order: number;

	label: string;
	index: number;
	visible: boolean;

	stack: number;

	indexAxis: 'x' | 'y';

	data: TElement[];
	dataset?: TDatasetElement;

	hidden: boolean;

	xAxisID?: string;
	yAxisID?: string;
	rAxisID?: string;
	iAxisID: string;
	vAxisID: string;

	xScale?: Scale;
	yScale?: Scale;
	rScale?: Scale;
	iScale?: Scale;
	vScale?: Scale;

	_sorted: boolean;
	_stacked: boolean;
	_parsed: any[];
}

interface ActiveDataPoint {
	datasetIndex: number;
	index: number;
}

interface ActiveElement extends ActiveDataPoint {
	element: Element;
}

declare class Chart<
	TType extends ChartType = ChartType,
	TData extends unknown[] = DefaultDataPoint<TType>,
	TLabel = unknown
	> {
	readonly platform: BasePlatform;
	readonly id: string;
	readonly canvas: HTMLCanvasElement;
	readonly ctx: CanvasRenderingContext2D;
	readonly config: ChartConfiguration<TType, TData, TLabel>
	readonly width: number;
	readonly height: number;
	readonly aspectRatio: number;
	readonly boxes: LayoutItem[];
	readonly currentDevicePixelRatio: number;
	readonly chartArea: ChartArea;
	readonly scales: { [key: string]: Scale };
	readonly scale: Scale | undefined;
	readonly attached: boolean;

	data: ChartData<TType, TData, TLabel>;
	options: ChartOptions<TType>;

	constructor(item: ChartItem, config: ChartConfiguration<TType, TData, TLabel>);

	clear(): this;
	stop(): this;

	resize(width: number, height: number): void;
	ensureScalesHaveIDs(): void;
	buildOrUpdateScales(): void;
	buildOrUpdateControllers(): void;
	reset(): void;
	update(mode?: UpdateMode): void;
	render(): void;
	draw(): void;

	getElementsAtEventForMode(e: Event, mode: string, options: InteractionOptions, useFinalPosition: boolean): InteractionItem[];

	getSortedVisibleDatasetMetas(): ChartMeta[];
	getDatasetMeta(datasetIndex: number): ChartMeta;
	getVisibleDatasetCount(): number;
	isDatasetVisible(datasetIndex: number): boolean;
	setDatasetVisibility(datasetIndex: number, visible: boolean): void;
	toggleDataVisibility(index: number): void;
	getDataVisibility(index: number): boolean;
	hide(datasetIndex: number): void;
	show(datasetIndex: number): void;

	getActiveElements(): ActiveElement[];
	setActiveElements(active: ActiveDataPoint[]): void;

	destroy(): void;
	toBase64Image(type?: string, quality?: any): string;
	bindEvents(): void;
	unbindEvents(): void;
	updateHoverStyle(items: Element, mode: 'dataset', enabled: boolean): void;

	static readonly version: string;
	static readonly instances: { [key: string]: Chart };
	static readonly registry: Registry;
	static getChart(key: string | CanvasRenderingContext2D | HTMLCanvasElement): Chart | undefined;
	static register(...items: ChartComponentLike[]): void;
	static unregister(...items: ChartComponentLike[]): void;
}

declare type ChartItem =
	| string
	| CanvasRenderingContext2D
	| OffscreenCanvasRenderingContext2D
	| HTMLCanvasElement
	| OffscreenCanvas
	| { canvas: HTMLCanvasElement | OffscreenCanvas }
	| ArrayLike<CanvasRenderingContext2D | HTMLCanvasElement | OffscreenCanvas>;

declare enum UpdateModeEnum {
	resize = 'resize',
	reset = 'reset',
	none = 'none',
	hide = 'hide',
	show = 'show',
	normal = 'normal',
	active = 'active'
}

type UpdateMode = keyof typeof UpdateModeEnum;

declare class DatasetController<TElement extends Element = Element, TDatasetElement extends Element = Element> {
	constructor(chart: Chart, datasetIndex: number);

	readonly chart: Chart;
	readonly index: number;
	readonly _cachedMeta: ChartMeta<TElement, TDatasetElement>;
	enableOptionSharing: boolean;

	linkScales(): void;
	getAllParsedValues(scale: Scale): number[];
	protected getLabelAndValue(index: number): { label: string; value: string };
	updateElements(elements: TElement[], start: number, count: number, mode: UpdateMode): void;
	update(mode: UpdateMode): void;
	updateIndex(datasetIndex: number): void;
	protected getMaxOverflow(): boolean | number;
	draw(): void;
	reset(): void;
	getDataset(): ChartDataset;
	getMeta(): ChartMeta<TElement, TDatasetElement>;
	getScaleForId(scaleID: string): Scale | undefined;
	configure(): void;
	initialize(): void;
	addElements(): void;
	buildOrUpdateElements(): void;

	getStyle(index: number, active: boolean): any;
	protected resolveDatasetElementOptions(active: boolean): any;
	protected resolveDataElementOptions(index: number, mode: UpdateMode): any;
	/**
	 * Utility for checking if the options are shared and should be animated separately.
	 * @protected
	 */
	protected getSharedOptions(options: any): undefined | any;
	/**
	 * Utility for determining if `options` should be included in the updated properties
	 * @protected
	 */
	protected includeOptions(mode: UpdateMode, sharedOptions: any): boolean;
	/**
	 * Utility for updating an element with new properties, using animations when appropriate.
	 * @protected
	 */

	protected updateElement(element: TElement | TDatasetElement, index: number | undefined, properties: any, mode: UpdateMode): void;
	/**
	 * Utility to animate the shared options, that are potentially affecting multiple elements.
	 * @protected
	 */

	protected updateSharedOptions(sharedOptions: any, mode: UpdateMode, newOptions: any): void;
	removeHoverStyle(element: TElement, datasetIndex: number, index: number): void;
	setHoverStyle(element: TElement, datasetIndex: number, index: number): void;

	parse(start: number, count: number): void;
	protected parsePrimitiveData(meta: ChartMeta<TElement, TDatasetElement>, data: any[], start: number, count: number): any[];
	protected parseArrayData(meta: ChartMeta<TElement, TDatasetElement>, data: any[], start: number, count: number): any[];
	protected parseObjectData(meta: ChartMeta<TElement, TDatasetElement>, data: any[], start: number, count: number): any[];
	protected getParsed(index: number): any;
	protected applyStack(scale: Scale, parsed: any[]): number;
	protected updateRangeFromParsed(
		range: { min: number; max: number },
		scale: Scale,
		parsed: any[],
		stack: boolean
	): void;
	protected getMinMax(scale: Scale, canStack?: boolean): { min: number; max: number };
}

interface DatasetControllerChartComponent extends ChartComponent {
	defaults: {
		datasetElementType?: string | null | false;
		dataElementType?: string | null | false;
		dataElementOptions?: string[];
		datasetElementOptions?: string[] | { [key: string]: string };
	};
}

type AnyObject = Record<string, unknown>;
interface Defaults extends CoreChartOptions, ElementChartOptions {
	controllers: {
		[key in ChartType]: DeepPartial<
			CoreChartOptions &
			PluginChartOptions &
			ElementChartOptions &
			DatasetChartOptions<key>[key] &
			ScaleChartOptions<key> &
			ChartTypeRegistry[key]['chartOptions']
			>;
	};

	scale: ScaleOptions;
	scales: {
		[key in ScaleType]: ScaleOptions<key>;
	};

	plugins: PluginOptions;

	set(values: AnyObject): AnyObject;
	set(scope: string, values: AnyObject): AnyObject;
	get(scope: string): AnyObject;

	/**
	 * Routes the named defaults to fallback to another scope/name.
	 * This routing is useful when those target values, like defaults.color, are changed runtime.
	 * If the values would be copied, the runtime change would not take effect. By routing, the
	 * fallback is evaluated at each access, so its always up to date.
	 *
	 * Example:
	 *
	 * 	defaults.route('elements.arc', 'backgroundColor', '', 'color')
	 *   - reads the backgroundColor from defaults.color when undefined locally
	 *
	 * @param scope Scope this route applies to.
	 * @param name Property name that should be routed to different namespace when not defined here.
	 * @param targetScope The namespace where those properties should be routed to.
	 * Empty string ('') is the root of defaults.
	 * @param targetName The target name in the target scope the property should be routed to.
	 */
	route(scope: string, name: string, targetScope: string, targetName: string): void;
}

declare const defaults: Defaults & DeepPartial<PluginChartOptions>;

interface Element<T = {}, O = {}> {
	readonly x: number;
	readonly y: number;
	readonly active: boolean;
	readonly options: O;

	tooltipPosition(useFinalPosition?: boolean): Point;
	hasValue(): boolean;
	getProps<P extends keyof T>(props: [P], final?: boolean): Pick<T, P>;
	getProps<P extends keyof T, P2 extends keyof T>(props: [P, P2], final?: boolean): Pick<T, P | P2>;
	getProps<P extends keyof T, P2 extends keyof T, P3 extends keyof T>(
		props: [P, P2, P3],
		final?: boolean
	): Pick<T, P | P2 | P3>;
	getProps<P extends keyof T, P2 extends keyof T, P3 extends keyof T, P4 extends keyof T>(
		props: [P, P2, P3, P4],
		final?: boolean
	): Pick<T, P | P2 | P3 | P4>;
	getProps<P extends keyof T, P2 extends keyof T, P3 extends keyof T, P4 extends keyof T, P5 extends keyof T>(
		props: [P, P2, P3, P4, P5],
		final?: boolean
	): Pick<T, P | P2 | P3 | P4 | P5>;
	getProps(props: (keyof T)[], final?: boolean): T;
}
declare const Element: {
	prototype: Element;
	new <T = {}, O = {}>(): Element<T, O>;
};

interface InteractionOptions {
	axis?: string;
	intersect?: boolean;
}

interface InteractionItem {
	element: Element;
	datasetIndex: number;
	index: number;
}

type InteractionModeFunction = (
	chart: Chart,
	e: ChartEvent,
	options: InteractionOptions,
	useFinalPosition?: boolean
) => InteractionItem[];

interface InteractionModeMap {
	/**
	 * Returns items at the same index. If the options.intersect parameter is true, we only return items if we intersect something
	 * If the options.intersect mode is false, we find the nearest item and return the items at the same index as that item
	 */
	index: InteractionModeFunction;

	/**
	 * Returns items in the same dataset. If the options.intersect parameter is true, we only return items if we intersect something
	 * If the options.intersect is false, we find the nearest item and return the items in that dataset
	 */
	dataset: InteractionModeFunction;
	/**
	 * Point mode returns all elements that hit test based on the event position
	 * of the event
	 */
	point: InteractionModeFunction;
	/**
	 * nearest mode returns the element closest to the point
	 */
	nearest: InteractionModeFunction;
	/**
	 * x mode returns the elements that hit-test at the current x coordinate
	 */
	x: InteractionModeFunction;
	/**
	 * y mode returns the elements that hit-test at the current y coordinate
	 */
	y: InteractionModeFunction;
}

type InteractionMode = keyof InteractionModeMap;

declare const Interaction: {
	modes: InteractionModeMap;
};

type LayoutPosition = 'left' | 'top' | 'right' | 'bottom' | 'chartArea';

interface LayoutItem {
	/**
	 * The position of the item in the chart layout. Possible values are
	 */
	position: LayoutPosition;
	/**
	 * The weight used to sort the item. Higher weights are further away from the chart area
	 */
	weight: number;
	/**
	 * if true, and the item is horizontal, then push vertical boxes down
	 */
	fullWidth: boolean;
	/**
	 * returns true if the layout item is horizontal (ie. top or bottom)
	 */
	isHorizontal(): boolean;
	/**
	 * Takes two parameters: width and height. Returns size of item
	 * @param width
	 * @param height
	 */
	update(width: number, height: number): number;

	/**
	 * Draws the element
	 */
	draw(): void;

	/**
	 * Returns an object with padding on the edges
	 */
	getPadding?(): ChartArea;

	/**
	 *  Width of item. Must be valid after update()
	 */
	width: number;
	/**
	 * Height of item. Must be valid after update()
	 */
	height: number;
	/**
	 * Left edge of the item. Set by layout system and cannot be used in update
	 */
	left: number;
	/**
	 * Top edge of the item. Set by layout system and cannot be used in update
	 */
	top: number;
	/**
	 * Right edge of the item. Set by layout system and cannot be used in update
	 */
	right: number;
	/**
	 *  Bottom edge of the item. Set by layout system and cannot be used in update
	 */
	bottom: number;
}

declare const layouts: {
	/**
	 * Register a box to a chart.
	 * A box is simply a reference to an object that requires layout. eg. Scales, Legend, Title.
	 * @param {Chart} chart - the chart to use
	 * @param {LayoutItem} item - the item to add to be laid out
	 */
	addBox(chart: Chart, item: LayoutItem): void;

	/**
	 * Remove a layoutItem from a chart
	 * @param {Chart} chart - the chart to remove the box from
	 * @param {LayoutItem} layoutItem - the item to remove from the layout
	 */
	removeBox(chart: Chart, layoutItem: LayoutItem): void;

	/**
	 * Sets (or updates) options on the given `item`.
	 * @param {Chart} chart - the chart in which the item lives (or will be added to)
	 * @param {LayoutItem} item - the item to configure with the given options
	 * @param options - the new item options.
	 */
	configure(
		chart: Chart,
		item: LayoutItem,
		options: { fullWidth?: number; position?: LayoutPosition; weight?: number }
	): void;

	/**
	 * Fits boxes of the given chart into the given size by having each box measure itself
	 * then running a fitting algorithm
	 * @param {Chart} chart - the chart
	 * @param {number} width - the width to fit into
	 * @param {number} height - the height to fit into
	 */
	update(chart: Chart, width: number, height: number): void;
};

interface PluginService {
	/**
	 * Calls enabled plugins for `chart` on the specified hook and with the given args.
	 * This method immediately returns as soon as a plugin explicitly returns false. The
	 * returned value can be used, for instance, to interrupt the current action.
	 * @param {Chart} chart - The chart instance for which plugins should be called.
	 * @param {string} hook - The name of the plugin method to call (e.g. 'beforeUpdate').
	 * @param {Array} [args] - Extra arguments to apply to the hook call.
	 * @returns {boolean} false if any of the plugins return false, else returns true.
	 */
	notify(chart: Chart, hook: string, args: any[]): boolean;
	invalidate(): void;
}

interface Plugin<O = {}> {
	id: string;

	/**
	 * @desc Called before initializing `chart`.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 */
	beforeInit?(chart: Chart, options: O): void;
	/**
	 * @desc Called after `chart` has been initialized and before the first update.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 */
	afterInit?(chart: Chart, options: O): void;
	/**
	 * @desc Called before updating `chart`. If any plugin returns `false`, the update
	 * is cancelled (and thus subsequent render(s)) until another `update` is triggered.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 * @returns {boolean} `false` to cancel the chart update.
	 */
	beforeUpdate?(chart: Chart, args: { mode: UpdateMode }, options: O): boolean | void;
	/**
	 * @desc Called after `chart` has been updated and before rendering. Note that this
	 * hook will not be called if the chart update has been previously cancelled.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 */
	afterUpdate?(chart: Chart, args: { mode: UpdateMode }, options: O): void;
	/**
	 * @desc Called during chart reset
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 * @since version 3.0.0
	 */
	reset?(chart: Chart, options: O): void;
	/**
	 * @desc Called before updating the `chart` datasets. If any plugin returns `false`,
	 * the datasets update is cancelled until another `update` is triggered.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} args - The call arguments.
	 * @param {UpdateMode} args.mode - The update mode.
	 * @param {object} options - The plugin options.
	 * @returns {boolean} false to cancel the datasets update.
	 * @since version 2.1.5
	 */
	beforeDatasetsUpdate?(chart: Chart, args: { mode: UpdateMode }, options: O): boolean | void;
	/**
	 * @desc Called after the `chart` datasets have been updated. Note that this hook
	 * will not be called if the datasets update has been previously cancelled.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} args - The call arguments.
	 * @param {UpdateMode} args.mode - The update mode.
	 * @param {object} options - The plugin options.
	 * @since version 2.1.5
	 */
	afterDatasetsUpdate?(chart: Chart, args: { mode: UpdateMode }, options: O): void;
	/**
	 * @desc Called before updating the `chart` dataset at the given `args.index`. If any plugin
	 * returns `false`, the datasets update is cancelled until another `update` is triggered.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} args - The call arguments.
	 * @param {number} args.index - The dataset index.
	 * @param {object} args.meta - The dataset metadata.
	 * @param {UpdateMode} args.mode - The update mode.
	 * @param {object} options - The plugin options.
	 * @returns {boolean} `false` to cancel the chart datasets drawing.
	 */
	beforeDatasetUpdate?(chart: Chart, args: { index: number; meta: ChartMeta, mode: UpdateMode }, options: O): boolean | void;
	/**
	 * @desc Called after the `chart` datasets at the given `args.index` has been updated. Note
	 * that this hook will not be called if the datasets update has been previously cancelled.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} args - The call arguments.
	 * @param {number} args.index - The dataset index.
	 * @param {object} args.meta - The dataset metadata.
	 * @param {UpdateMode} args.mode - The update mode.
	 * @param {object} options - The plugin options.
	 */
	afterDatasetUpdate?(chart: Chart, args: { index: number; meta: ChartMeta, mode: UpdateMode }, options: O): void;
	/**
	 * @desc Called before laying out `chart`. If any plugin returns `false`,
	 * the layout update is cancelled until another `update` is triggered.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 * @returns {boolean} `false` to cancel the chart layout.
	 */
	beforeLayout?(chart: Chart, options: O): boolean | void;
	/**
	 * @desc Called after the `chart` has been laid out. Note that this hook will not
	 * be called if the layout update has been previously cancelled.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 */
	afterLayout?(chart: Chart, options: O): void;
	/**
	 * @desc Called before rendering `chart`. If any plugin returns `false`,
	 * the rendering is cancelled until another `render` is triggered.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 * @returns {boolean} `false` to cancel the chart rendering.
	 */
	beforeRender?(chart: Chart, options: O): boolean | void;
	/**
	 * @desc Called after the `chart` has been fully rendered (and animation completed). Note
	 * that this hook will not be called if the rendering has been previously cancelled.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 */
	afterRender?(chart: Chart, options: O): void;
	/**
	 * @desc Called before drawing `chart` at every animation frame. If any plugin returns `false`,
	 * the frame drawing is cancelled untilanother `render` is triggered.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 * @returns {boolean} `false` to cancel the chart drawing.
	 */
	beforeDraw?(chart: Chart, options: O): boolean | void;
	/**
	 * @desc Called after the `chart` has been drawn. Note that this hook will not be called
	 * if the drawing has been previously cancelled.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 */
	afterDraw?(chart: Chart, options: O): void;
	/**
	 * @desc Called before drawing the `chart` datasets. If any plugin returns `false`,
	 * the datasets drawing is cancelled until another `render` is triggered.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 * @returns {boolean} `false` to cancel the chart datasets drawing.
	 */
	beforeDatasetsDraw?(chart: Chart, options: O): boolean | void;
	/**
	 * @desc Called after the `chart` datasets have been drawn. Note that this hook
	 * will not be called if the datasets drawing has been previously cancelled.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 */
	afterDatasetsDraw?(chart: Chart, options: O): void;
	/**
	 * @desc Called before drawing the `chart` dataset at the given `args.index` (datasets
	 * are drawn in the reverse order). If any plugin returns `false`, the datasets drawing
	 * is cancelled until another `render` is triggered.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} args - The call arguments.
	 * @param {number} args.index - The dataset index.
	 * @param {object} args.meta - The dataset metadata.
	 * @param {object} options - The plugin options.
	 * @returns {boolean} `false` to cancel the chart datasets drawing.
	 */
	beforeDatasetDraw?(chart: Chart, args: { index: number; meta: ChartMeta }, options: O): boolean | void;
	/**
	 * @desc Called after the `chart` datasets at the given `args.index` have been drawn
	 * (datasets are drawn in the reverse order). Note that this hook will not be called
	 * if the datasets drawing has been previously cancelled.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} args - The call arguments.
	 * @param {number} args.index - The dataset index.
	 * @param {object} args.meta - The dataset metadata.
	 * @param {object} options - The plugin options.
	 */
	afterDatasetDraw?(chart: Chart, args: { index: number; meta: ChartMeta }, options: O): void;
	/**
	 * @desc Called before processing the specified `event`. If any plugin returns `false`,
	 * the event will be discarded.
	 * @param {Chart} chart - The chart instance.
	 * @param {ChartEvent} event - The event object.
	 * @param {object} options - The plugin options.
	 * @param {boolean} replay - True if this event is replayed from `Chart.update`
	 */
	beforeEvent?(chart: Chart, event: ChartEvent, options: O, replay: boolean): void;
	/**
	 * @desc Called after the `event` has been consumed. Note that this hook
	 * will not be called if the `event` has been previously discarded.
	 * @param {Chart} chart - The chart instance.
	 * @param {ChartEvent} event - The event object.
	 * @param {object} options - The plugin options.
	 * @param {boolean} replay - True if this event is replayed from `Chart.update`
	 */
	afterEvent?(chart: Chart, event: ChartEvent, options: O, replay: boolean): void;
	/**
	 * @desc Called after the chart as been resized.
	 * @param {Chart} chart - The chart instance.
	 * @param {number} size - The new canvas display size (eq. canvas.style width & height).
	 * @param {object} options - The plugin options.
	 */
	resize?(chart: Chart, size: number, options: O): void;
	/**
	 * Called after the chart as been destroyed.
	 * @param {Chart} chart - The chart instance.
	 * @param {object} options - The plugin options.
	 */
	destroy?(chart: Chart, options: O): void;
}

declare type ChartComponentLike = ChartComponent | ChartComponent[] | { [key: string]: ChartComponent };

/**
 * Please use the module's default export which provides a singleton instance
 * Note: class is exported for typedoc
 */
interface Registry {
	readonly controllers: TypedRegistry<DatasetController>;
	readonly elements: TypedRegistry<Element>;
	readonly plugins: TypedRegistry<Plugin>;
	readonly scales: TypedRegistry<Scale>;

	add(...args: ChartComponentLike[]): void;
	remove(...args: ChartComponentLike[]): void;

	addControllers(...args: ChartComponentLike[]): void;
	addElements(...args: ChartComponentLike[]): void;
	addPlugins(...args: ChartComponentLike[]): void;
	addScales(...args: ChartComponentLike[]): void;

	getController(id: string): DatasetController | undefined;
	getElement(id: string): Element | undefined;
	getPlugin(id: string): Plugin | undefined;
	getScale(id: string): Scale | undefined;
}

declare const registry: Registry;

interface Tick {
	value: number;
	label?: string;
	major?: boolean;
}

interface CoreScaleOptions {
	/**
	 * Controls the axis global visibility (visible when true, hidden when false). When display: 'auto', the axis is visible only if at least one associated dataset is visible.
	 * @default true
	 */
	display: boolean | 'auto';
	/**
	 * Reverse the scale.
	 * @default false
	 */
	reverse: boolean;
	/**
	 * The weight used to sort the axis. Higher weights are further away from the chart area.
	 * @default true
	 */
	weight: number;
	/**
	 * Callback called before the update process starts.
	 */
	beforeUpdate(axis: Scale): void;
	/**
	 * Callback that runs before dimensions are set.
	 */
	beforeSetDimensions(axis: Scale): void;
	/**
	 * Callback that runs after dimensions are set.
	 */
	afterSetDimensions(axis: Scale): void;
	/**
	 * Callback that runs before data limits are determined.
	 */
	beforeDataLimits(axis: Scale): void;
	/**
	 * Callback that runs after data limits are determined.
	 */
	afterDataLimits(axis: Scale): void;
	/**
	 * Callback that runs before ticks are created.
	 */
	beforeBuildTicks(axis: Scale): void;
	/**
	 * Callback that runs after ticks are created. Useful for filtering ticks.
	 */
	afterBuildTicks(axis: Scale): void;
	/**
	 * Callback that runs before ticks are converted into strings.
	 */
	beforeTickToLabelConversion(axis: Scale): void;
	/**
	 * Callback that runs after ticks are converted into strings.
	 */
	afterTickToLabelConversion(axis: Scale): void;
	/**
	 * Callback that runs before tick rotation is determined.
	 */
	beforeCalculateTickRotation(axis: Scale): void;
	/**
	 * Callback that runs after tick rotation is determined.
	 */
	afterCalculateTickRotation(axis: Scale): void;
	/**
	 * Callback that runs before the scale fits to the canvas.
	 */
	beforeFit(axis: Scale): void;
	/**
	 * Callback that runs after the scale fits to the canvas.
	 */
	afterFit(axis: Scale): void;
	/**
	 * Callback that runs at the end of the update process.
	 */
	afterUpdate(axis: Scale): void;
}

interface Scale<O extends CoreScaleOptions = CoreScaleOptions> extends Element<{}, O>, ChartArea {
	readonly id: string;
	readonly type: string;
	readonly ctx: CanvasRenderingContext2D;
	readonly chart: Chart;

	width: number;
	height: number;

	maxWidth: number;
	maxHeight: number;

	paddingTop: number;
	paddingBottom: number;
	paddingLeft: number;
	paddingRight: number;

	axis: string;
	labelRotation: number;
	min: number;
	max: number;
	ticks: Tick[];
	getMatchingVisibleMetas(type?: string): ChartMeta[];

	draw(chartArea: ChartArea): void;
	drawTitle(chartArea: ChartArea): void;
	drawLabels(chartArea: ChartArea): void;
	drawGrid(chartArea: ChartArea): void;

	/**
	 * @param {number} pixel
	 * @return {number}
	 */
	getDecimalForPixel(pixel: number): number;
	/**
	 * Utility for getting the pixel location of a percentage of scale
	 * The coordinate (0, 0) is at the upper-left corner of the canvas
	 * @param {number} decimal
	 * @return {number}
	 */
	getPixelForDecimal(decimal: number): number;
	/**
	 * Returns the location of the tick at the given index
	 * The coordinate (0, 0) is at the upper-left corner of the canvas
	 * @param {number} index
	 * @return {number}
	 */
	getPixelForTick(index: number): number;
	/**
	 * Used to get the label to display in the tooltip for the given value
	 * @param {*} value
	 * @return {string}
	 */
	getLabelForValue(value: number): string;
	/**
	 * Returns the location of the given data point. Value can either be an index or a numerical value
	 * The coordinate (0, 0) is at the upper-left corner of the canvas
	 * @param {*} value
	 * @param {number} [index]
	 * @return {number}
	 */
	getPixelForValue(value: number, index: number): number;

	/**
	 * Used to get the data value from a given pixel. This is the inverse of getPixelForValue
	 * The coordinate (0, 0) is at the upper-left corner of the canvas
	 * @param {number} pixel
	 * @return {*}
	 */
	getValueForPixel(pixel: number): number | undefined;

	getBaseValue(): number;
	/**
	 * Returns the pixel for the minimum chart value
	 * The coordinate (0, 0) is at the upper-left corner of the canvas
	 * @return {number}
	 */
	getBasePixel(): number;

	init(options: O): void;
	parse(raw: any, index: number): any;
	getUserBounds(): { min: number; max: number; minDefined: boolean; maxDefined: boolean };
	getMinMax(canStack: boolean): { min: number; max: number };
	invalidateCaches(): void;
	getPadding(): ChartArea;
	getTicks(): Tick[];
	getLabels(): string[];
	beforeUpdate(): void;
	update(maxWidth: number, maxHeight: number, margins: any): void;
	configure(): void;
	afterUpdate(): void;
	beforeSetDimensions(): void;
	setDimensions(): void;
	afterSetDimensions(): void;
	beforeDataLimits(): void;
	determineDataLimits(): void;
	afterDataLimits(): void;
	beforeBuildTicks(): void;
	buildTicks(): Tick[];
	afterBuildTicks(): void;
	beforeTickToLabelConversion(): void;
	generateTickLabels(ticks: Tick[]): void;
	afterTickToLabelConversion(): void;
	beforeCalculateLabelRotation(): void;
	calculateLabelRotation(): void;
	afterCalculateLabelRotation(): void;
	beforeFit(): void;
	fit(): void;
	afterFit(): void;

	isHorizontal(): boolean;
	isFullWidth(): boolean;
}
declare const Scale: {
	prototype: Scale;
	new <O extends CoreScaleOptions = CoreScaleOptions>(cfg: any): Scale<O>;
};

interface ScriptAbleScaleContext {
	chart: Chart;
	scale: Scale;
	index: number;
	tick: Tick;
}

type ScriptAbleScale<T> = T | ((ctx: ScriptAbleScaleContext) => T);

declare const Ticks: {
	formatters: {
		/**
		 * Formatter for value labels
		 * @param value the value to display
		 * @return {string|string[]} the label to display
		 */
		values(value: any): string | string[];
		/**
		 * Formatter for numeric ticks
		 * @param tickValue the value to be formatted
		 * @param index the position of the tickValue parameter in the ticks array
		 * @param ticks the list of ticks being converted
		 * @return string representation of the tickValue parameter
		 */
		numeric(tickValue: number, index: number, ticks: { value: number }[]): string;
		/**
		 * Formatter for logarithmic ticks
		 * @param tickValue the value to be formatted
		 * @param index the position of the tickValue parameter in the ticks array
		 * @param ticks the list of ticks being converted
		 * @return string representation of the tickValue parameter
		 */
		logarithmic(tickValue: number, index: number, ticks: { value: number }[]): string;
	};
};

interface TypedRegistry<T> {
	/**
	 * @param {ChartComponent} item
	 * @returns {string} The scope where items defaults were registered to.
	 */
	register(item: ChartComponent): string;
	get(id: string): T | undefined;
	unregister(item: ChartComponent): void;
}

interface ParsingOptions {
  /**
   * How to parse the dataset. The parsing can be disabled by specifying parsing: false at chart options or dataset. If parsing is disabled, data must be sorted and in the formats the associated chart type and scales use internally.
   */
  parsing:
  {
    [key: string]: string;
  }
  | false;

  /**
   * Chart.js is fastest if you provide data with indices that are unique, sorted, and consistent across datasets and provide the normalized: true option to let Chart.js know that you have done so.
   */
  normalized: boolean;
}

interface ControllerDatasetOptions extends ParsingOptions {
  /**
   * How to clip relative to chartArea. Positive value allows overflow, negative value clips that many pixels inside chartArea. 0 = clip at chartArea. Clipping can also be configured per side: clip: {left: 5, top: false, right: -2, bottom: 0}
   */
  clip: number | ChartArea;
  /**
   * The label for the dataset which appears in the legend and tooltips.
   */
  label: string;
  /**
   * The drawing order of dataset. Also affects order for stacking, tooltip and legend.
   */
  order: number;

  /**
   * The ID of the group to which this dataset belongs to (when stacked, each group will be a separate stack).
   */
  stack: string;
}

interface BarControllerDatasetOptions
  extends ControllerDatasetOptions,
    ScriptableAndArrayOptions<BarOptions>,
    ScriptableAndArrayOptions<CommonHoverOptions> {
  /**
   * The base axis of the dataset. 'x' for vertical bars and 'y' for horizontal bars.
   * @default 'x'
   */
  indexAxis: 'x' | 'y';
  /**
   * The ID of the x axis to plot this dataset on.
   */
  xAxisID: string;
  /**
   * The ID of the y axis to plot this dataset on.
   */
  yAxisID: string;

  /**
   * Percent (0-1) of the available width each bar should be within the category width. 1.0 will take the whole category width and put the bars right next to each other.
   * @default 0.9
   */
  barPercentage: number;
  /**
   * Percent (0-1) of the available width each category should be within the sample width.
   * @default 0.8
   */
  categoryPercentage: number;

  /**
   * Manually set width of each bar in pixels. If set to 'flex', it computes "optimal" sample widths that globally arrange bars side by side. If not set (default), bars are equally sized based on the smallest interval.
   */
  barThickness: number | 'flex';

  /**
   * Set this to ensure that bars are not sized thicker than this.
   */
  maxBarThickness: number;

  /**
   * Set this to ensure that bars have a minimum length in pixels.
   */
  minBarLength: number;
}

interface BarControllerChartOptions {
  /**
   * Should null or undefined values be omitted from drawing
   */
  skipNull?: boolean;
}

interface BarController extends DatasetController {}
declare const BarController: ChartComponent & {
  prototype: BarController;
  new (chart: Chart, datasetIndex: number): BarController;
};

interface BubbleControllerDatasetOptions
  extends ControllerDatasetOptions,
    ScriptableAndArrayOptions<PointOptions>,
    ScriptableAndArrayOptions<PointHoverOptions> {}

interface BubbleDataPoint {
  /**
   * X Value
   */
  x: number;

  /**
   * Y Value
   */
  y: number;

  /**
   * Bubble radius in pixels (not scaled).
   */
  r: number;
}

interface BubbleController extends DatasetController {}
declare const BubbleController: ChartComponent & {
  prototype: BubbleController;
  new (chart: Chart, datasetIndex: number): BubbleController;
};

interface LineControllerDatasetOptions
  extends ControllerDatasetOptions,
    ScriptableAndArrayOptions<PointPrefixedOptions>,
    ScriptableAndArrayOptions<PointPrefixedHoverOptions>,
    ScriptableOptions<LineOptions>,
    ScriptableOptions<LineHoverOptions> {
  /**
   * The ID of the x axis to plot this dataset on.
   */
  xAxisID: string;
  /**
   * The ID of the y axis to plot this dataset on.
   */
  yAxisID: string;

  /**
   * If true, lines will be drawn between points with no or null data. If false, points with NaN data will create a break in the line. Can also be a number specifying the maximum gap length to span. The unit of the value depends on the scale used.
   * @default false
   */
  spanGaps: boolean | number;

  showLine: boolean;
}

interface LineControllerChartOptions {
  /**
   * If true, lines will be drawn between points with no or null data. If false, points with NaN data will create a break in the line. Can also be a number specifying the maximum gap length to span. The unit of the value depends on the scale used.
   * @default false
   */
  spanGaps: boolean | number;
  /**
   * If false, the lines between points are not drawn.
   * @default true
   */
  showLine: boolean;
}

interface LineController extends DatasetController {}
declare const LineController: ChartComponent & {
  prototype: LineController;
  new (chart: Chart, datasetIndex: number): LineController;
};

type ScatterControllerDatasetOptions = LineControllerDatasetOptions;

interface ScatterDataPoint {
  x: number;
  y: number;
}

type ScatterControllerChartOptions = LineControllerChartOptions;

interface ScatterController extends LineController {}
declare const ScatterController: ChartComponent & {
  prototype: ScatterController;
  new (chart: Chart, datasetIndex: number): ScatterController;
};

interface DoughnutControllerDatasetOptions
  extends ControllerDatasetOptions,
    ScriptableAndArrayOptions<ArcOptions>,
    ScriptableAndArrayOptions<ArcHoverOptions> {

  /**
   * Sweep to allow arcs to cover.
   * @default 2 * Math.PI
   */
  circumference: number;

  /**
   * Starting angle to draw this dataset from.
   * @default -0.5 * Math.PI
   */
  rotation: number;

  /**
   * The relative thickness of the dataset. Providing a value for weight will cause the pie or doughnut dataset to be drawn with a thickness relative to the sum of all the dataset weight values.
   * @default 1
   */
  weight: number;
}

interface DoughnutAnimationOptions {
  /**
   * 	If true, the chart will animate in with a rotation animation. This property is in the options.animation object.
   * @default true
   */
  animateRotate: boolean;

  /**
   * If true, will animate scaling the chart from the center outwards.
   * @default false
   */
  animateScale: boolean;
}

interface DoughnutControllerChartOptions {
  /**
   * The percentage of the chart that is cut out of the middle. (50 - for doughnut, 0 - for pie)
   * @default 50
   */
  cutoutPercentage: number;

  /**
   * Starting angle to draw arcs from.
   * @default -0.5 * Math.PI
   */
  rotation: number;

  /**
   * Sweep to allow arcs to cover.
   * @default 2 * Math.PI
   */
  circumference: number;

  animation: DoughnutAnimationOptions;
}

type DoughnutDataPoint = number;

interface DoughnutController extends DatasetController {
  readonly innerRadius: number;
  readonly outerRadius: number;
  readonly offsetX: number;
  readonly offsetY: number;

  getRingIndex(datasetIndex: number): number;
  calculateTotal(): number;
  calculateCircumference(value: number): number;
}

declare const DoughnutController: ChartComponent & {
  prototype: DoughnutController;
  new (chart: Chart, datasetIndex: number): DoughnutController;
};

type PieControllerDatasetOptions = DoughnutControllerDatasetOptions;
type PieControllerChartOptions = DoughnutControllerChartOptions;
type PieAnimationOptions = DoughnutAnimationOptions;

type PieDataPoint = DoughnutDataPoint;

interface PieController extends DoughnutController {}
declare const PieController: ChartComponent & {
  prototype: PieController;
  new (chart: Chart, datasetIndex: number): PieController;
};

interface PolarAreaControllerDatasetOptions extends DoughnutControllerDatasetOptions {
  /**
   * Arc angle to cover. - for polar only
   * @default circumference / (arc count)
   */
  angle: number;
}

type PolarAreaAnimationOptions = DoughnutAnimationOptions;

interface PolarAreaControllerChartOptions {
  /**
   * Starting angle to draw arcs for the first item in a dataset. In degrees, 0 is at top.
   * @default 0
   */
  startAngle: number;

  animation: PolarAreaAnimationOptions;
}

interface PolarAreaController extends DoughnutController {
  countVisibleElements(): number;
}
declare const PolarAreaController: ChartComponent & {
  prototype: PolarAreaController;
  new (chart: Chart, datasetIndex: number): PolarAreaController;
};

interface RadarControllerDatasetOptions
  extends ControllerDatasetOptions,
    ScriptableOptions<PointPrefixedOptions>,
    ScriptableOptions<PointPrefixedHoverOptions>,
    ScriptableOptions<LineOptions>,
    ScriptableOptions<LineHoverOptions> {
  /**
   * The ID of the x axis to plot this dataset on.
   */
  xAxisID: string;
  /**
   * The ID of the y axis to plot this dataset on.
   */
  yAxisID: string;

  /**
   * If true, lines will be drawn between points with no or null data. If false, points with NaN data will create a break in the line. Can also be a number specifying the maximum gap length to span. The unit of the value depends on the scale used.
   */
  spanGaps: boolean | number;

  /**
   * If false, the line is not drawn for this dataset.
   */
  showLine: boolean;
}

type RadarControllerChartOptions = LineControllerChartOptions;

interface RadarController extends DatasetController {}
declare const RadarController: ChartComponent & {
  prototype: RadarController;
  new (chart: Chart, datasetIndex: number): RadarController;
};

export { InteractionItem as $, DateAdapter as A, BarControllerDatasetOptions as B, ControllerDatasetOptions as C, DoughnutControllerDatasetOptions as D, Animation as E, AnimationEvent$1 as F, Animator as G, Animations as H, ChartMeta as I, ActiveDataPoint as J, ActiveElement as K, LineControllerDatasetOptions as L, Chart as M, ChartItem as N, UpdateMode as O, ParsingOptions as P, DatasetController as Q, RadarControllerDatasetOptions as R, ScatterControllerDatasetOptions as S, DatasetControllerChartComponent as T, UpdateModeEnum as U, AnyObject as V, Defaults as W, defaults as X, Element as Y, InteractionOptions as Z, _adapters as _, BarControllerChartOptions as a, FontSpec as a$, InteractionModeFunction as a0, InteractionModeMap as a1, InteractionMode as a2, Interaction as a3, LayoutPosition as a4, LayoutItem as a5, layouts as a6, PluginService as a7, Plugin as a8, ChartComponentLike as a9, PointPrefixedHoverOptions as aA, PointElement as aB, BarProps as aC, BarOptions as aD, BorderRadius as aE, BarHoverOptions as aF, BarElement as aG, ElementChartOptions as aH, Color as aI, ChartEvent as aJ, Point as aK, ChartComponent as aL, TimeUnit as aM, ChartArea as aN, ScriptableContext as aO, Scriptable as aP, ScriptableOptions as aQ, ScriptableAndArray as aR, ScriptableAndArrayOptions as aS, CoreInteractionOptions as aT, HoverInteractionOptions as aU, CoreChartOptions as aV, EasingFunction as aW, AnimationCommonSpec as aX, AnimationPropertySpec as aY, AnimationSpecContainer as aZ, AnimationOptions as a_, Registry as aa, registry as ab, Tick as ac, CoreScaleOptions as ad, Scale as ae, ScriptAbleScaleContext as af, ScriptAbleScale as ag, Ticks as ah, TypedRegistry as ai, VisualElement as aj, CommonOptions as ak, CommonHoverOptions as al, Segment as am, ArcProps as an, ArcOptions as ao, ArcHoverOptions as ap, ArcElement as aq, LineProps as ar, LineOptions as as, LineHoverOptions as at, LineElement as au, PointProps as av, PointStyle as aw, PointOptions as ax, PointHoverOptions as ay, PointPrefixedOptions as az, BarController as b, TextAlign as b0, BasePlatform as b1, BasicPlatform as b2, DomPlatform as b3, Filler as b4, FillerOptions as b5, FillTarget as b6, ComplexFillTarget as b7, FillerControllerDatasetOptions as b8, Legend as b9, TimeScaleOptions as bA, TimeScale as bB, TimeSeriesScale as bC, RadialLinearScaleOptions as bD, RadialLinearScale as bE, DeepPartial as bF, DistributiveArray as bG, CartesianScaleTypeRegistry as bH, RadialScaleTypeRegistry as bI, ScaleTypeRegistry as bJ, ScaleType as bK, ChartTypeRegistry as bL, ChartType as bM, ScaleOptions as bN, DatasetChartOptions as bO, ScaleChartOptions as bP, ChartOptions as bQ, DefaultDataPoint as bR, ChartDatasetProperties as bS, ChartDataset as bT, ChartData as bU, ChartConfiguration as bV, LegendItem as ba, LegendElement as bb, LegendOptions as bc, LegendChartOptions as bd, Title as be, TitleOptions as bf, TitleChartOptions as bg, TooltipAlignment as bh, TooltipModel as bi, Tooltip as bj, TooltipCallbacks as bk, TooltipPlugin as bl, TooltipOptions as bm, TooltipChartOptions as bn, TooltipItem as bo, PluginOptions as bp, PluginChartOptions as bq, GridLineOptions as br, TickOptions as bs, CartesianScaleOptions as bt, CategoryScaleOptions as bu, CategoryScale as bv, LinearScaleOptions as bw, LinearScale as bx, LogarithmicScaleOptions as by, LogarithmicScale as bz, BubbleControllerDatasetOptions as c, BubbleDataPoint as d, BubbleController as e, LineControllerChartOptions as f, LineController as g, ScatterDataPoint as h, ScatterControllerChartOptions as i, ScatterController as j, DoughnutAnimationOptions as k, DoughnutControllerChartOptions as l, DoughnutDataPoint as m, DoughnutController as n, PieControllerDatasetOptions as o, PieControllerChartOptions as p, PieAnimationOptions as q, PieDataPoint as r, PieController as s, PolarAreaControllerDatasetOptions as t, PolarAreaAnimationOptions as u, PolarAreaControllerChartOptions as v, PolarAreaController as w, RadarControllerChartOptions as x, RadarController as y, DateAdapterBase as z };
