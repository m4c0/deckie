#include <windows.h>

#pragma comment(lib, "user32.lib")

static HINSTANCE g_hinst;

static HWND g_hwnd_sketchpad;
static void toggle_sketchpad(void) {
  if (g_hwnd_sketchpad) {
    DestroyWindow(g_hwnd_sketchpad);
    return;
  }

  g_hwnd_sketchpad = CreateWindowEx(
      WS_EX_TOPMOST,
      "m4c0-sketchpad", "Deckie Sketch",
      WS_POPUP,
      30, 30, GetSystemMetrics(SM_CXSCREEN) - 60, GetSystemMetrics(SM_CYSCREEN) - 60,
      NULL, NULL, g_hinst, NULL);
  ShowWindow(g_hwnd_sketchpad, SW_SHOW);
  UpdateWindow(g_hwnd_sketchpad);
  SetForegroundWindow(g_hwnd_sketchpad);
}

static LRESULT wndproc_actionpanel(HWND hwnd, UINT msg, WPARAM w_param, LPARAM l_param) {
  switch (msg) {
    case WM_DESTROY:
      PostQuitMessage(0);
      return 0;

    case WM_HOTKEY:
      SetForegroundWindow(hwnd);
      return 0;

    case WM_KEYDOWN:
      if (HIWORD(l_param) & KF_REPEAT) return 0;

      switch (LOWORD(w_param)) {
        case VK_SPACE: toggle_sketchpad(); break;
      }
      return 0;
  }

  return DefWindowProc(hwnd, msg, w_param, l_param);
}

static LRESULT wndproc_sketchpad(HWND hwnd, UINT msg, WPARAM w_param, LPARAM l_param) {
  switch (msg) {
    case WM_DESTROY:
      g_hwnd_sketchpad = NULL;
      return 0;

    case WM_PAINT: {
      PAINTSTRUCT ps;
      HDC dc = BeginPaint(hwnd, &ps);
      // FillRect(dc, &ps.rcPaint, (HBRUSH)(COLOR_WINDOW + 1));
      EndPaint(hwnd, &ps);
      return 0;
    }

    // case WM_ERASEBKGND: return 1;
  }
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
  g_hinst = h_instance;

  if (register_actionpanel_class(h_instance)) return 1;
  if (register_sketchpad_class(h_instance)) return 1;

  HWND hwnd = CreateWindow(
      "m4c0-actionpanel", "Deckie",
      WS_POPUP,
      GetSystemMetrics(SM_CXSCREEN) - 30 - 64, GetSystemMetrics(SM_CYSCREEN) - 30 - 64, 64, 64, 
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

