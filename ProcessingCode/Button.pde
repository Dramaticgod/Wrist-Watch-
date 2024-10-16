class Button {
  int x, y, w, h;
  String label;
  color bgColor;
  color textColor;

  Button(int x, int y, int w, int h, String label, color bgColor, color textColor) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.bgColor = bgColor;
    this.textColor = textColor;
  }

  void display() {
    fill(bgColor);
    rect(x, y, w, h, 5); // Draw button with rounded corners
    fill(textColor);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2); // Display the label
  }

  // Check if the button is clicked
  boolean isClicked(int mouseX, int mouseY) {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
  
  
  void updateLabel(String newLabel) {
    this.label = newLabel;
  }
}
