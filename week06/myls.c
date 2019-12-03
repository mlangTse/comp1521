// myls.c ... my very own "ls" implementation

#include <sys/types.h>
#include <sys/stat.h>

#include <dirent.h>
#include <err.h>
#include <errno.h>
#include <fcntl.h>
#include <grp.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef __linux__
# include <bsd/string.h>
#endif
#include <sysexits.h>
#include <unistd.h>

#define MAXDIRNAME 256
#define MAXFNAME 256
#define MAXNAME 24

char *rwxmode (mode_t, char *);
char *username (uid_t, char *);
char *groupname (gid_t, char *);

int main (int argc, char *argv[])
{
	// string buffers for various names
    char uname[MAXNAME+1];
    char gname[MAXNAME+1];
    char mode[MAXNAME+1];

	// collect the directory name, with "." as default
	char dirname[MAXDIRNAME] = ".";
	if (argc >= 2)
		strlcpy (dirname, argv[1], MAXDIRNAME);

	// check that the name really is a directory
	struct stat info;
	if (stat (dirname, &info) < 0)
		err (EX_OSERR, "%s", dirname);

	if (! S_ISDIR (info.st_mode)) {
		errno = ENOTDIR;
		err (EX_DATAERR, "%s", dirname);
	}

	// open the directory to start reading
	DIR *df; 

	// read directory entries
	struct dirent *entry;
	df = opendir(dirname);
	
	while ((entry = readdir(df))){
	    if (entry->d_name[0] == '.') continue;
		chdir(dirname);
	    lstat (entry->d_name, &info);
	    printf ("%s  %-8.8s %-8.8s %8lld  %s\n", 
	                rwxmode (info.st_mode, mode),
	                username (info.st_uid, uname),
	                groupname(info.st_gid, gname),
	                (long long) info.st_size,
	                entry->d_name
        );
	    
	}

	// finish up
	closedir(df);

	return EXIT_SUCCESS;
}

// convert octal mode to -rwxrwxrwx string
char *rwxmode (mode_t mode, char *str)
{
    char *cur = str;
    unsigned int mask = 1;
    mask = mask << 8;
    switch (mode & S_IFMT) {
	    case S_IFDIR:  cur[0] = 'd'; break;
	    case S_IFLNK:  cur[0] = 'l'; break;
	    case S_IFREG:  cur[0] = '-'; break;
	    default:       cur[0] = '?'; break;
	}
	
    for (int i = 1; i < 10; i++){
	    if ((mask & mode) > 0) {
            if (i % 3 == 1){
                cur[i] = 'r';
            } else if (i % 3 == 2){
                cur[i] = 'w';
            } else {
                cur[i] = 'x';
            }
        } else {
            cur[i] = '-';
        }
        mask = mask >> 1;
    }
	return str;
}

// convert user id to user name
char *username (uid_t uid, char *name)
{
	struct passwd *uinfo = getpwuid (uid);
	if (uinfo != NULL)
		snprintf (name, MAXNAME, "%s", uinfo->pw_name);
	else
		snprintf (name, MAXNAME, "%d?", (int) uid);
	return name;
}

// convert group id to group name
char *groupname (gid_t gid, char *name)
{
	struct group *ginfo = getgrgid (gid);
	if (ginfo != NULL)
		snprintf (name, MAXNAME, "%s", ginfo->gr_name);
	else
		snprintf (name, MAXNAME, "%d?", (int) gid);
	return name;
}
