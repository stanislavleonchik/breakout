uses GraphWPF, WPFObjects, System.Timers;
const brickCount = 19;
const brickWidth = 50;
const brickHeight = 20;
const gapBetweenBricks = 2;
const sliderGap = 100;
const sliderWidth = 100;
const sliderHeight = 20;
const topGap = 100;
const ballSize = 15;
const startBrickCount = brickCount * 10;
var wallColors := Arr(Colors.Red, Colors.Orange, Colors.Yellow, Colors.Green, Colors.Cyan);
var Slider: RectangleWPF := nil;
var Ball: CircleWPF := nil;
var gameTimer := new Timer(5);
var brickCounter := 0;
var canChangeDyAfterSlider := true;
var canChangeDx := true;
var canBreakBrick := true;

procedure DrawWall(xWall, yWall: integer);
begin
  for var i := 0 to 18 do
  begin
    for var j := 1 to 10 do
    begin
      new RectangleWPF(
      i * (brickWidth + gapBetweenBricks),
      j * (brickHeight + gapBetweenBricks),
      brickWidth,
      brickHeight,
      wallColors[(j - 1) div 2])
    end;
  end;
end;

procedure MoveSlider(x, y: real; mousebutton: integer);
begin
  Slider.Left := round(min(round(window.width) - sliderWidth, max(0, x - sliderWidth div 2)));
end;

procedure CreateSlider(xSlider, ySlider: integer);
begin
  Slider := new RectangleWPF(xSlider, ySlider, sliderWidth, sliderHeight, colors.Black);
  OnMouseMove += MoveSlider;
end;

function getCollidingObject() : ObjectWPF;
begin
  if objectunderpoint(ball.center.x + ballsize + 1, ball.center.y + ballsize + 1) <> nil then
  result := objectunderpoint(ball.center.x + ballsize + 1, ball.center.y + ballsize + 1)
  else if objectunderpoint(ball.center.x - ballsize - 1, ball.center.y - ballsize - 1) <> nil then
  result := objectunderpoint(ball.center.x - ballsize - 1, ball.center.y - ballsize - 1)
  else if objectunderpoint(ball.center.x + ballsize + 1, ball.center.y - ballsize - 1) <> nil then
  result := objectunderpoint(ball.center.x + ballsize + 1, ball.center.y - ballsize - 1)
  else if objectunderpoint(ball.center.x - ballsize - 1, ball.center.y + ballsize + 1) <> nil then
  result := objectunderpoint(ball.center.x - ballsize - 1, ball.center.y + ballsize + 1);
end;


procedure Tick(source: Object; e: ElapsedEventArgs);
begin
  /// уничтожение блока
  if (getCollidingObject() <> nil) and (getCollidingObject() <> Slider) and canBreakBrick  then begin
    getCollidingObject().Destroy;
    ball.Dy *= -1;
    brickCounter += 1;
    canBreakBrick := false;
    canChangeDyAfterSlider := true;
    canChangeDx := true;
  end
  /// slider
  else if ((objectunderpoint(ball.center.x + ballsize + 1, ball.center.y + ballsize + 1) = slider) or
     (objectunderpoint(ball.center.x - ballsize - 1, ball.center.y + ballsize + 1) = slider)) and canChangeDyAfterSlider then begin
     canChangeDyAfterSlider := false;
     canBreakBrick := true;
     canChangeDx := true;
     ball.dy *= -1;
     end
  /// верхняя граница
  else if (ball.Center.Y - ballSize) < 0 then begin
  ball.Dy *= -1;
  canChangeDyAfterSlider := true;
  canBreakBrick := true;
  canChangeDx := true;
  end
  /// правая и левая граница
  else if (((ball.Center.X + ballSize) >= window.Width) or (ball.Center.X - ballSize <= 0)) and canChangeDx then begin
  ball.dx *= -1;
  canChangeDyAfterSlider := true;
  canBreakBrick := true;
  canChangeDx := false;
  end
  /// нижняя граница - выход
  else if ball.Center.Y > window.Height then begin
    gametimer.Stop;
    window.Clear;
    new TextWPF(
    window.width / 2 - (55 * 3 + 20),
    window.height / 2, 55, 'YOU LOSE', Colors.Red
    );
    slider.Destroy;
    ball.Destroy;
  end
  else if brickCounter = startBrickCount then begin
    gametimer.Stop;
    window.Clear;
    new TextWPF(
    window.width / 2 - (55 * 3 + 20),
    window.height / 2, 55, 'YOU WIN', Colors.Green
    );
    slider.Destroy;
  end; 
  ball.Move;
end;


procedure CreateBall(xBall, yBall: integer);
begin
  Ball := new CircleWPF(xBall, yBall, ballSize, colors.Black);
end;

procedure Init();
begin
  DrawWall(0, 0);
  CreateSlider(round(window.Width / 2), round(window.Height - sliderGap));
  CreateBall(round(window.Width / 2), round(window.Height / 2));
end;

begin
  window.Width := (brickCount) * (brickWidth + gapBetweenBricks) - gapBetweenBricks;
  window.Height := brickCount * brickWidth div 3 * 2;
  Init();
  ball.dx := 4;
  ball.dy := 5;
  gameTimer.Elapsed += Tick;
  gameTimer.Start;
end.