// wspawn
// g++ -o ../plugin/vjde/wspawn wspawn.cpp -mwindows

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <string>
#include <windows.h>

using namespace std;

void exit_friendly(void)
{
    puts("请不要单独运行wSpawn.");
    exit(0);
}

int main( int argc, char *argv[] )
{
    HANDLE  hWrite = NULL;
    DWORD   dwWrited;
    int     i = 0, ret = 0, len = 0;
    char    psBuffer[256];
    FILE*   child_output;
    string  command_line = "";

    // 检查命令行，如存在管道句柄，则将其转换为HANDLE类型
    if (argc < 2)
        exit_friendly();
    if (!stricmp(argv[1], "-h"))
    {
        if (argc < 4)
            exit_friendly();
        hWrite = (HANDLE)atoi(argv[2]);
        i = 3;
    }
    else
        i = 1;

    // 提取要执行的命令
    for (; i < argc; i++)
    {
        command_line += argv[i];
        command_line += " ";
    }

    // 使用_popen创建子进程并重定向其标准输出到文件指针中
    if( (child_output = _popen( command_line.c_str(), "rt" )) == NULL )
        exit( 1 );

    while( !feof( child_output ) )
    {
        if( fgets( psBuffer, 255, child_output ) != NULL )
        {
            if (hWrite)
            {
                // 将子进程的标准输出写入管道，提供给自己的父进程
                // 格式是先写数据块长度（0表示结束），再写数据块内容
                len = strlen(psBuffer);
                WriteFile(hWrite, &len, sizeof(int), &dwWrited, NULL);
                WriteFile(hWrite, psBuffer, len, &dwWrited, NULL);
            }
            else
                // 如命令行未提供管道句柄，则直接打印输出
                printf(psBuffer);
        }
    }

    // 写"0"表示所有数据都已写完
    len = 0;
    if (hWrite)
        WriteFile(hWrite, &len, sizeof(int), &dwWrited, NULL);

    return _pclose( child_output );
}
