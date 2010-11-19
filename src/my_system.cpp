#ifdef _WIN32
#include <windows.h>
#include <winuser.h>
#include <string>
#include <stdio.h>
unsigned int my_system(const char *cmd,char *result,int maxLen){
    PROCESS_INFORMATION pi;
    STARTUPINFO siStartInfo;
    SECURITY_ATTRIBUTES saAttr;
    std::string Output, tmp;
    char command_line[2048];
    DWORD dwRead;
    char* buf; int len;
    HANDLE hRead, hWrite;


    saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
    saAttr.bInheritHandle = TRUE;
    saAttr.lpSecurityDescriptor = NULL;
    if (!CreatePipe(&hRead, &hWrite, &saAttr, 0))
    {
        return 0;
    }

    memset(&pi, 0, sizeof(pi));
    sprintf(command_line, "wspawn -h %d %s", (unsigned int)hWrite,cmd);
    ZeroMemory( &siStartInfo, sizeof(STARTUPINFO) );
    siStartInfo.cb = sizeof(STARTUPINFO);
    siStartInfo.wShowWindow = SW_HIDE;
    siStartInfo.dwFlags = STARTF_USESHOWWINDOW;
    if (!CreateProcess( NULL, command_line, NULL, NULL, TRUE,
                        0, NULL, NULL, &siStartInfo, &pi))
    {
        return 0;
    }

    if(!ReadFile( hRead, &len, sizeof(int), &dwRead, NULL) || dwRead == 0)
        return 0;
    while(len)
    {
        buf = new char[len + 1];
        memset(buf, 0, len + 1);

        if(!ReadFile( hRead, buf, len, &dwRead, NULL) || dwRead == 0)
            return 0;

        tmp = buf;
        //tmp.Replace("\n", "\r\n");
        Output += tmp;


        delete[] buf;
        if(!ReadFile( hRead, &len, sizeof(int), &dwRead, NULL) || dwRead == 0)
            return 0;
    }

    //printf("%d \n%s\n",Output.length(),Output.c_str());
    _snprintf(result,maxLen,"%s",Output.c_str());
    WaitForSingleObject(pi.hProcess, 30000);

    CloseHandle(hRead);
    CloseHandle(hWrite);

    return Output.size();
}
#else
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
unsigned int my_system(const char* pCmd, char* pResult, int size) {
	int fd[2]; 
	int pid; 
	int count; 
	int left; 
	char* p = 0; 
	int maxlen = size - 1; 
	memset(pResult, 0, size); 
	if(pipe(fd)) 
	{ 
		printf("pipe error\n"); 
		return 0; 
	} 
	if((pid = fork()) == 0) 
	{// chile process 
		int fd2[2]; 
		if(pipe(fd2)) 
		{ 
			printf("pipe2 error\n"); 
			return 0; 
		} 
		close(1); 
		dup2(fd2[1],1); 
		close(fd[0]); 
		close(fd2[1]); 
		system(pCmd); 
		read(fd2[0], pResult, maxlen); 
		pResult[strlen(pResult)-1] = 0; 
		write(fd[1], pResult, strlen(pResult)); 
		close(fd2[0]); 
		exit(0); 
	} 
	// parent process 
	close(fd[1]); 
	p = pResult; 
	left = maxlen; 
	while((count = read(fd[0], p, left))) { 
		p += count; 
		left -= count; 
		if(left == 0) 
			break; 
	} 
	close(fd[0]); 
	return 1; 
	
}
#endif
