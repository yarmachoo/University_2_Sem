#include <windows.h>
#include <iostream>

#define ID_RADIOBUTTON1 101
#define ID_RADIOBUTTON2 102
#define ID_RADIOBUTTON3 103
#define ID_RADIOBUTTON4 104
#define ID_AREA 105

int functionID = 1;

void SetFont(HWND hwndControl, const wchar_t* fontName, int fontSize) {
    HFONT hFont = CreateFont(
        fontSize, 0, 0, 0, FW_NORMAL, TRUE, FALSE, FALSE, DEFAULT_CHARSET, OUT_OUTLINE_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, DEFAULT_PITCH, fontName);

    if (hFont) {
        // Отправляем сообщение WM_SETFONT
        SendMessage(hwndControl, WM_SETFONT, (WPARAM)hFont, TRUE);
    }
}

void DrawGraph(HDC hdc, HWND hwnd) {
    bool flag = 0;
    float x = 0, ten = 10, two = 2;
    float y = 0, yOld = 0;
    float area = 0;
    WCHAR areaText[100];

    //draw ox, oy
    MoveToEx(hdc, 0 + 10, 0, NULL);
    LineTo(hdc, 0 + 10, 200);
    MoveToEx(hdc, 0 + 10, 200, NULL);
    LineTo(hdc, 400, 200);
    for (int i = 1; i < 10; i++)
    {
        SetPixel(hdc, 10 - i, i, RGB(153, 51, 255));
        SetPixel(hdc, i + 10, i, RGB(153, 51, 255));
        SetPixel(hdc, 400 - i, 200 - i, RGB(153, 51, 255));
        SetPixel(hdc, 400 - i, 200 + i, RGB(153, 51, 255));
    }
    MoveToEx(hdc, 0, 200, NULL);

    for (x = -380; x <= 380; x += 1) {
        if (functionID == 1) {
            //y = x;

            _asm {
                finit
                fld x
                fstp y
                fwait
            }
        }
        else if (functionID == 2) {
            //y = x * x / 10 / 10;
            _asm {
                finit
                fld x
                fmul x
                fdiv ten
                fdiv ten
                fstp y
                fwait
            }
        }
        else if (functionID == 3) {
            //y = x * x * x / 10 / 10 / 10;
            _asm {
                finit
                fld x
                fmul x
                fmul x
                fdiv ten
                fdiv ten
                fdiv ten
                fstp y
                fwait
            }
        }
        else {
            if (x != 0)
            {
                _asm {
                    finit
                    fld1
                    fdiv x
                    fmul ten
                    fmul ten
                    fmul ten
                    fstp y
                    fwait
                }
                //y = 1. / x * 1000;
            }
            else
            {
                yOld = 0;
                continue;
            }
        }
        if (abs(y) > 200)
        {
            continue;
        }
        int a = (yOld)-abs(y);
        while (a != 0 && yOld != 0)
        {
            SetPixel(hdc, x + 200, 200 - (int)yOld + a, RGB(204, 204, 102));
            if (a > 0)
                a--;
            if (a < 0)
                a++;
        }
        SetPixel(hdc, x + 200, 200 - (int)y, RGB(204, 204, 102));
        if (flag)
        {
            _asm {
                finit
                fld yOld
                fabs
                fstp yOld
                fld y
                fabs
                fadd yOld
                fdiv two
                fadd area
                fstp area
                fwait
            }
            //area += (abs(yOld) + abs(y)) / 2;
        }
        yOld = y;
        flag = 1;
    }
    std::swprintf(areaText, 100, L"Площадь %f", area);
    SetFont(GetDlgItem(hwnd, ID_AREA), L"Times New Roman", 16);
    SetWindowText(GetDlgItem((hwnd), ID_AREA), areaText);
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    HDC hdc;
    PAINTSTRUCT ps;

    switch (msg) {
    case WM_CREATE:
        CreateWindow(TEXT("button"), TEXT("y = x"),
            WS_VISIBLE | WS_CHILD | BS_RADIOBUTTON,
            20, 220, 100, 30, hwnd, (HMENU)ID_RADIOBUTTON1, NULL, NULL);

        CreateWindow(TEXT("button"), TEXT("y = x^2"),
            WS_VISIBLE | WS_CHILD | BS_RADIOBUTTON,
            20, 250, 100, 30, hwnd, (HMENU)ID_RADIOBUTTON2, NULL, NULL);

        CreateWindow(TEXT("button"), TEXT("y = x^3"),
            WS_VISIBLE | WS_CHILD | BS_RADIOBUTTON,
            20, 280, 100, 30, hwnd, (HMENU)ID_RADIOBUTTON3, NULL, NULL);

        CreateWindow(TEXT("button"), TEXT("y = 1/x"),
            WS_VISIBLE | WS_CHILD | BS_RADIOBUTTON,
            20, 310, 100, 30, hwnd, (HMENU)ID_RADIOBUTTON4, NULL, NULL);

        CreateWindow(TEXT("STATIC"), TEXT("Area: "),
            WS_VISIBLE | WS_CHILD,
            20, 340, 200, 30, hwnd, (HMENU)ID_AREA, NULL, NULL);
        break;

    case WM_COMMAND:
        switch (LOWORD(wParam)) {
        case ID_RADIOBUTTON1:
            functionID = 1;
            InvalidateRect(hwnd, NULL, TRUE);
            break;
        case ID_RADIOBUTTON2:
            functionID = 2;
            InvalidateRect(hwnd, NULL, TRUE);
            break;
        case ID_RADIOBUTTON3:
            functionID = 3;
            InvalidateRect(hwnd, NULL, TRUE);
            break;
        case ID_RADIOBUTTON4:
            functionID = 4;
            InvalidateRect(hwnd, NULL, TRUE);
            break;
        }
        break;

    case WM_PAINT:
        hdc = BeginPaint(hwnd, &ps);
        DrawGraph(hdc, hwnd);
        EndPaint(hwnd, &ps);
        break;

    case WM_DESTROY:
        PostQuitMessage(0);
        break;
    }

    return DefWindowProc(hwnd, msg, wParam, lParam);
}


int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    MSG  msg;
    HWND hwnd;
    WNDCLASS wc = { 0 };
    wc.lpszClassName = TEXT("Graph Plotter");
    wc.hInstance = hInstance;
    wc.hbrBackground = GetSysColorBrush(COLOR_3DFACE);
    wc.lpfnWndProc = WndProc;
    wc.hCursor = LoadCursor(0, IDC_ARROW);

    RegisterClass(&wc);
    hwnd = CreateWindow(wc.lpszClassName, TEXT("Graph Plotter"),
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        150, 150, 500, 400, 0, 0, hInstance, 0);

    while (GetMessage(&msg, NULL, 0, 0)) {
        DispatchMessage(&msg);
    }

    return (int)msg.wParam;
}
