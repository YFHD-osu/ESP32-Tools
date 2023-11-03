from concurrent.futures import ThreadPoolExecutor, wait

from typing import TYPE_CHECKING
if TYPE_CHECKING:
  from cv2.typing import MatLike

from bmp2hex import bmp2hex
from PIL import Image # pip install Pillow
import cv2 # pip install opencv-python
import os, sys, time

executor = ThreadPoolExecutor(max_workers=10)
frame_list = []
img_list = []
ascii_array = []

def get_fps(video: cv2.VideoCapture) -> float:
  (major_ver, minor_ver, subminor_ver) = (cv2.__version__).split('.')
  if int(major_ver) < 3: return video.get(cv2.cv.CV_CAP_PROP_FPS)
  else : return video.get(cv2.CAP_PROP_FPS)

def convert_c_array(frame: int):
  filename = f".\\oled_TMP\\bmps\\frame{frame}.bmp"
  output = bmp2hex(filename, 16 , 0 , True, False, False, False, False)
  program = f"const unsigned char frame{frame} [] PROGMEM = " + "{\n" + output + "};\n\n"

  # Append text at the end of file
  ascii_array.append(program)

def fit_size(image: 'Image') -> tuple[int, int, int, int]:
  width, height = image.size

  if width / height > 2:
    height = round(height / (width / 128))
    width = 128
    xoffset = 0
    yoffset = round((64 - height) / 2)

  elif width/height < 2:
    width =  round(width / (height / 64))
    height = 64
    xoffset = round((128 - width) / 2)
    yoffset = 0

  else:
    width = 128
    height = 64
    xoffset = yoffset = 0 

  return (width, height, xoffset, yoffset)

def convert_bmp(h):
  image_file = Image.open(f"./oled_TMP/pngs/{h}") # open colour image
  
  width, height, xoffset, yoffset = fit_size(image_file)
  newsize = (width,height)
  
  imagecpy = image_file.resize(newsize)
  
  image_file.paste((0,0,0), [0,0,image_file.size[0],image_file.size[1]])
  default_size = (128,64)

  new_image = image_file.resize(default_size)
  new_image.paste(imagecpy, (xoffset,yoffset))
  new_image = new_image.convert('1') # convert image to black and white
  new_image.save(f'./oled_TMP/bmps/{h[:-4]}.bmp')

  image_file.close()
  return

def write_video(count, images: 'MatLike'):
	cv2.imwrite(".\\oled_TMP\\pngs\\frame%d.png" % count, images)
  
	return

def read_frames(video: cv2.VideoCapture) -> int:
  tasks = []
  frame_count = 0
  success, images = video.read()
  while success:
    success, images = video.read()
    if success == False: break
    tasks.append(executor.submit(write_video, frame_count, images))
    print(f"成功讀取第 {frame_count} 幀...", end="\r")
    frame_count += 1

  video.release()
  print("")
  wait(tasks)
  return frame_count

path = [os.path.join("./", "oled_TMP"),os.path.join("./oled_TMP", "pngs"),os.path.join("./oled_TMP", "bmps") ]
for i in path:
	try: os.mkdir(i)
	except: pass

for dirPath, dirNames, fileNames in os.walk("./oled_TMP/pngs"):
  for names in fileNames:
    img_list.append(names)

# print("[ 100% ] 完成!                                         ")
# print("開始bmp檔轉成 cpp ascii art 並稱成程式碼...")

def get_define_array(frame: int) -> str:
  context = ""
  for i in range(0,frame):
    context += f"frame{i},"
    context += "\n" if i % 11 == 10 else ""
  return context

def get_code(frame: int): return f"""
{' '.join(ascii_array)}
const unsigned char* video_array[{frame}] = {{
  {get_define_array(frame)}
}};

const unsigned int frame_count = {frame}; 
"""

def main():
  start_time = time.time()
  if len(sys.argv) < 2:
    print("傳入的參數不足，至少需要一部影片來源")
    sys.exit()

  vidcap = cv2.VideoCapture(sys.argv[1])
  frame_count = read_frames(vidcap)
  
  file_count = len(img_list)
  print("開始將 png 檔轉成 單色bmp檔...")
  tasks = []
  for index in range(frame_count):
    tasks.append(executor.submit(convert_bmp, index))
    percent = round(index / (file_count+1) * 100)
    print (f"[{percent}%] 處理: {index} ({index+1} / {file_count})", end = "\r")
  wait(tasks)

  tasks = []
  for index in range(frame_count):
    percent = round(frame_count / (file_count+1) * 100)
    print (f"[{percent}%] 處理: frame{index} ({frame_count+1} / {file_count})", end = "\r")
    tasks.append(executor.submit(convert_c_array, index))
  wait(tasks)

  # print(sys.argv[0])
  print(f"影片讀取完畢, 共{frame_count}幀, 耗時: {time.time() - start_time}s" + " "*20)

  with open(".\\video.h", "a") as file:
    file.write(get_code(frame_count))

if __name__ == "__main__": main()