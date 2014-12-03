from PIL import Image

text = Image.open("pbmtext_cpc.png").crop((16,16,112,80))
number = 32
verilog = ""
for y in range(8):
  for x in range(12):
    line = "16'h" + hex(number)[2:] + ": ascii_mask = {"
    for i in range(8):
      row = "\n\t8'b"
      for j in range(8):
        row += "1" if text.getpixel((8*x+j,8*y+i)) == 255 else "0"
      line += row + ("," if i != 7 else "")
    verilog += line + "\n\t};\n"
    number += 1
print verilog
