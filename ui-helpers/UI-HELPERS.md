# Ui.setGaugeStyle

`Ui.setGaugeStyle(gauge, red, green, blue, colorfactor, type, fontsize, textcss)`

This function can generate a variety of styles for a Gauge, using a predefined type and deciding on the RGB tint.
Besides R,G,B. the function takes the following parameters:

 - colorfactor: How much darker the background of the gauge should be. Default is 3.5.
 - type: The gradient style to base the looks on. See image below.
 - fontsize: If set, it will call setFontSize on the gauge.
 - textcss: Styling for the Gauge text. Defaults to `[[padding-left: 0.2em; font: "Helvetica";]]`

![image](https://user-images.githubusercontent.com/4033825/128509746-546e284d-2b68-4b6d-aec0-03bf34ecf577.png)
