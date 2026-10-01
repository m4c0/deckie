#include <windows.h>

#pragma comment(lib, "user32.lib")

static LRESULT wndproc_actionpanel(HWND hwnd, UINT msg, WPARAM w_param, LPARAM l_param) {
  switch (msg) {
    case WM_DESTROY:
      PostQuitMessage(0);
      return 0;

    case WM_HOTKEY:
      SetForegroundWindow(hwnd);
      return 0;
  }

  return DefWindowProc(hwnd, msg, w_param, l_param);
}

static LRESULT wndproc_sketchpad(HWND hwnd, UINT msg, WPARAM w_param, LPARAM l_param) {
  return DefWindowProc(hwnd, msg, w_param, l_param);
}

static int register_actionpanel_class(HINSTANCE h_instance) {
  HICON h_icon = LoadIcon(h_instance, "IDI_APPICON");

  WNDCLASSEX wcex  = {
    .cbSize        = sizeof(WNDCLASSEX),
    .style         = CS_HREDRAW | CS_VREDRAW,
    .lpfnWndProc   = &wndproc_actionpanel,
    .hInstance     = h_instance,
    .hIcon         = h_icon,
    .hCursor       = LoadCursor(NULL, IDC_ARROW),
    .hbrBackground = (HBRUSH)(COLOR_WINDOW + 1),
    .lpszClassName = "m4c0-actionpanel",
    .hIconSm       = h_icon,
  };
  if (!RegisterClassEx(&wcex)) {
    MessageBox(NULL, "Failed to register window class", "Unhandled error", 0);
    return 1;
  }
  return 0;
}

static int register_sketchpad_class(HINSTANCE h_instance) {
  WNDCLASSEX wcex  = {
    .cbSize        = sizeof(WNDCLASSEX),
    .style         = CS_HREDRAW | CS_VREDRAW,
    .lpfnWndProc   = &wndproc_sketchpad,
    .hInstance     = h_instance,
    .hCursor       = LoadCursor(NULL, IDC_ARROW),
    .lpszClassName = "m4c0-sketchpad",
  };
  if (!RegisterClassEx(&wcex)) {
    MessageBox(NULL, "Failed to register window class", "Unhandled error", 0);
    return 1;
  }
  return 0;
}

int WinMain(HINSTANCE h_instance, HINSTANCE h_prev, LPSTR cmd_line, int cmd_show) {
  if (register_actionpanel_class(h_instance)) return 1;
  if (register_sketchpad_class(h_instance)) return 1;

  HWND hwnd = CreateWindow(
      "m4c0-actionpanel", "Deckie",
      WS_OVERLAPPEDWINDOW,
      30, GetSystemMetrics(SM_CYFULLSCREEN) - 30 - 32, 32, 32, 
      NULL, NULL, h_instance, NULL);
  if (!hwnd) {
    MessageBox(NULL, "Failed to create window", "Unhandled error", 0);
    return 1;
  }

  ShowWindow(hwnd, cmd_show);
  UpdateWindow(hwnd);

  RegisterHotKey(hwnd, 0xbeba, MOD_ALT | MOD_SHIFT, VK_OEM_5);

  MSG msg;
  while (GetMessage(&msg, 0, 0, 0)) {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }

  UnregisterHotKey(hwnd, 0xbeba); // I bet this is not needed
  return msg.wParam;
}

