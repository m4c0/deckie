#include <windows.h>

#pragma comment(lib, "user32.lib")

int WinMain(HINSTANCE h_instance, HINSTANCE h_prev, LPSTR cmd_line, int cmd_show) {
  MSG msg;
  while (GetMessage(&msg, 0, 0, 0)) {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }
  return msg.wParam;
}

