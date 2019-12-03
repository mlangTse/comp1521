// mysh.c ... a minimal shell
// Started by John Shepherd, October 2017
// Completed by <<MINGLANG XIE>>, July 2019

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>

#include <assert.h>
#include <ctype.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define DEFAULT_PATH "/bin:/usr/bin"
#define DBUG

static void execute (char **, char **, char **);
static bool isExecutable (char *);
static char **tokenise (const char *, const char *);
static void freeTokens (char **);
static char *trim (char *);
static size_t strrspn (const char *, const char *);


// Environment variables are pointed to by `environ', an array of
// strings terminated by a NULL value -- something like:
//     { "VAR1=value", "VAR2=value", NULL }
extern char **environ;

int main (int argc, char *argv[])
{
	// grab the `PATH' environment variable;
	// if it isn't set, use the default path defined above
	char *pathp;
	if ((pathp = getenv ("PATH")) == NULL)
		pathp = DEFAULT_PATH;
	char **path = tokenise (pathp, ":");

#ifdef DBUG
	for (int i = 0; path[i] != NULL; i++)
		printf ("dir[%d] = %s\n", i, path[i]);
#endif

	// main loop: print prompt, read line, execute command
	char line_[BUFSIZ];
	printf ("mysh$ ");
	while (fgets (line_, BUFSIZ, stdin) != NULL) {
		char *line = trim (line_); // remove leading/trailing space
		if (strcmp (line, "exit") == 0) break;
		if (strcmp (line, "") == 0) { printf ("mysh$ "); continue; }

		pid_t pid;   // pid of child process
		int stat;	 // return status of child

		/// TODO: implement the `tokenise, fork, execute, cleanup' code
		char **cmd = tokenise (line, " ");

		if (strcmp(cmd[0], "cd") == 0) {
		    if(cmd[1] == NULL) {
		        chdir(getenv("HOME"));
		    } else {
		        chdir(cmd[1]);
		    }
		    printf ("mysh$ ");
			continue;
		} else if (strcmp(cmd[0], "pwd") == 0) {
			char buffer[BUFSIZ];
			getcwd(buffer, BUFSIZ);
			printf("%s\n", buffer);
			continue;
		}
		if ((pid = fork()) != 0) {
			wait(&stat);
		} else {
			execute (cmd, path, environ);
		}
		freeTokens(cmd);
		printf ("mysh$ ");
	}
	printf ("\n");

	freeTokens (path);

	return EXIT_SUCCESS;
}

// execute: run a program, given command-line args, path and envp
static void execute (char **args, char **path, char **envp)
{
	/// TODO: implement the `find-the-executable and execve(3) it' code
	int flag = 0;
	char *cat;
	if (args[0][0] == '/' || args[0][0] == '.'){
		if (isExecutable (args[0])) {
			execve(args[0], args, envp);
			flag = 1;
			return;
		}
	} else {
		for (int i = 0; path[i] != NULL; i++) {
			cat = path[i];
			strcat(cat, "/");
			strcat(cat, args[0]);
			if (isExecutable (cat)) {
				flag = 1;
				break;
			}
		}
	}

	if (!flag) {
		perror("command not found\n");
		exit(1);
	} else {
		printf("Executing %s\n", cat);
		if (!execve(cat, args, envp)) {
			perror("Exec failed\n");
			exit(1);
		}
	}
}

/// isExecutable: check whether this process can execute a file
static bool isExecutable (char *cmd)
{
	struct stat s;
	// must be accessible
	if (stat (cmd, &s) < 0) return false;
	// must be a regular file
	if (! S_ISREG (s.st_mode)) return false;
	// if it's owner executable by us, ok
	if (s.st_uid == getuid () && s.st_mode & S_IXUSR) return true;
	// if it's group executable by us, ok
	if (s.st_gid == getgid () && s.st_mode & S_IXGRP) return true;
	// if it's other executable by us, ok
	if (s.st_mode & S_IXOTH) return true;
	// otherwise, no, we can't execute it.
	return false;
}

/// tokenise: split a string around a set of separators
/// create an array of separate strings
/// final array element contains NULL
static char **tokenise (const char *str_, const char *sep)
{
	char **results  = NULL;
	size_t nresults = 0;

	// strsep(3) modifies the input string and the pointer to it,
	// so make a copy and remember where we started.
	char *str = strdup (str_);
	char *tmp = str;

	char *tok;
	while ((tok = strsep (&str, sep)) != NULL) {
		// "push" this token onto the list of resulting strings
		results = realloc (results, ++nresults * sizeof (char *));
		results[nresults - 1] = strdup (tok);
	}

	results = realloc (results, ++nresults * sizeof (char *));
	results[nresults - 1] = NULL;

	free (tmp);
	return results;
}

/// freeTokens: free memory associated with array of tokens
static void freeTokens (char **toks)
{
	for (int i = 0; toks[i] != NULL; i++)
		free (toks[i]);
	free (toks);
}

/// trim: remove leading and trailing whitespace from a string
static char *trim (char *str)
{
	char *space = " \r\n\t";
	str[strrspn (str, space) + 1] = '\0'; // skip trailing whitespace
	str = &str[strspn (str, space)];      // skip leading whitespace
	return str;
}

/// strrspn: find a suffix substring made up of any of `set'.
/// like `strspn(3)', except from the end of the string.
static size_t strrspn (const char *str, const char *set)
{
	size_t len;
	for (len = strlen (str); len != 0; len--)
		if (strchr (set, str[len]) == NULL)
			break;
	return len;
}
