#!/usr/bin/env python3

import sys
try:
    assert sys.version_info >= (3,8)
except:
    print("Python 3.8+ required")
    exit(1)

"""
Typing 'oval' or 'oval l' will display the list of targets, as described in in ovalfile.py.
Each target is the association between a name and a shell command.

Typing 'oval r <name>' will execute the shell command associated with the given name
One can execute several ones sequentially: 'oval r <name1> <name2>...'

Typing 'oval v <name>' copy the log file '<name>.out' into the ref file '<name>.ref'.
Typing 'oval d <name>' compare the log file '<name>.out' with the ref file '<name>.ref'.
Typing 'oval fo <name>' show the filtered part of '<name>.out'.
Typing 'oval fr <name>' show the filtered part of '<name>.ref'.
Typing 'oval c <name>' crypt '<name>.ref' into '<name>.ref'.

One can use wildcards: 'oval r <pattern1> <pattern2>...'
The only wildcard character is '%'.
One can check how a given pattern expands : 'oval l <pattern>'.

On top of the targets, the configuration ovalfile.py can include a list of filters.

The ones in run_filters_out describe some lines to be erased from the output.

The ones in diff_filters_in describe the lines to be compared. If the regular
expression has two groups, it is considered as a pair name-value. A dictionary
will be built, the comparison will be between the current output and the
ref dictionaries.

"""

import argparse
import os
import os.path
import re
import subprocess
import hashlib
import logging
import concurrent.futures
import difflib


# ==========================================
# Custom logging

class VarFormatter(logging.Formatter):

    'Customized formatting for console'

    default_formatter = logging.Formatter('%(levelname)s in %(name)s: %(message)s')

    def __init__(self, formats):
        """ formats is a dict { loglevel : logformat } """
        super(VarFormatter, self).__init__()
        self.formatters = {}
        for loglevel in formats:
            self.formatters[loglevel] = logging.Formatter(formats[loglevel])

    def format(self, record):
        formatter = self.formatters.get(record.levelno, self.default_formatter)
        return formatter.format(record)


class InfoOnlyFilter(logging.Filter):

    def filter(self, record):
        return record.levelno == logging.INFO


console_handler = logging.StreamHandler()
console_handler.setFormatter(VarFormatter({
    logging.DEBUG: '(%(message)s)',
    logging.INFO: '%(message)s',
    logging.WARNING: 'warning: %(message)s',
    logging.ERROR: 'ERROR: %(message)s',
    logging.CRITICAL: 'CRITICAL ERROR: %(message)s',
}))
console_handler.setLevel(logging.INFO)

script_name = os.path.basename(sys.argv[0])
if script_name.endswith('.py'):
    script_name = script_name[:-3]

log_file_name = "."+script_name+".log"
log_file_handler = logging.FileHandler(log_file_name, mode="w", encoding="utf-8")
log_file_handler.setFormatter( \
    logging.Formatter("%(asctime)s :: %(name)s :: %(levelname)-8s :: %(message)s"))
log_file_handler.setLevel(logging.DEBUG)

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
logger.addHandler(console_handler)
logger.addHandler(log_file_handler)


# ==========================================
# SUBCOMMAND: Build

def apply_build(target,multi,expanded):
    command = 'make {}.exe'.format(target['name'])
    logging.info(command)
    proc = subprocess.run(command, shell=True, executable='bash', check=True)
    return proc.returncode


# ==========================================
# SUBCOMMAND: Run

def apply_run(target,multi,expanded):
    time_option = target.get("time","off")
    if ((time_option=="real") or (time_option=="user")):
      sh_command = "(time ({})) 2>&1 | tee {}.out ; test ${{PIPESTATUS[0]}} -eq 0".format(target["command"], target['name'])
    else:
      sh_command = "({}) 2>&1 | tee {}.out ; test ${{PIPESTATUS[0]}} -eq 0".format(target["command"], target['name'])
    out_file_name = "{}.out".format(target['name'])
    # version originale :  stderr=subprocess.STDOUT
    proc = subprocess.run(sh_command, shell=True, executable='bash', stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    with open(out_file_name, 'w') as out_content:
        runexps = [re.compile('^' + f.replace('%', '.*') + '$') for f in target['run_filters_out']]
        diffexps = [re.compile('^' + f.replace('%', '.*') + '$') for f in target['diff_filters_in']]
        for line in proc.stdout.splitlines():
            fmatches = [fexp.match(line) for fexp in runexps]
            if [fmatch for fmatch in fmatches if fmatch]:
                continue
            out_content.write(line + '\n')
            if multi:
                fmatches = [fexp.match(line) for fexp in diffexps]
                if [fmatch for fmatch in fmatches if fmatch]:
                    logging.info(target['name'] + ": " + line)
            else:
                logging.info(line)
    return proc.returncode


# ==========================================
# SUBCOMMAND: Diff

time_exp = re.compile('^(\w+)\s+([0-9]+)m([.0-9]+)s$')

def apply_diff(target,multi,expanded):

    # if a line has two matching groups, we suppose it a a key/value pair
    # and put it in a dictionary. Else, it is put in a list.
    # ATTENTION : la partie cryptage n'est pas operationnelle
    # pour les filtres de diff qui ont plusieurs groupes !!!

    time_option = target.get("time","off")
    logging.debug('process target {}'.format(target['name']))
    if not target['out']:
        logging.warning('lacking file {}.out'.format(target['name']))
        return
    if not target['ref'] and not target['md5']:
        logging.warning('lacking file {}.ref or {}.md5'.format(target['name'], target['name']))
        return
    out_file_name = target['out']
    if target['ref']:
        ref_file_name = target['ref']
        md5 = False
    else:
        ref_file_name = target['md5']
        md5 = True
    fexps = [re.compile('^' + f.replace('%', '.*') + '$') for f in target['diff_filters_in']]
    if multi or expanded:
        prefix = target['name'] + ': '
    else:
        prefix = ''

    # collect matching groups in output
    proc1 = subprocess.run("cat {} 2>&1".format(out_file_name),
                           shell=True, executable='bash', stdout=subprocess.PIPE, stderr=subprocess.PIPE , universal_newlines=True)
    out_log_matches = []
    out_md5_matches = []
    out_log_dict = {}
    out_md5_dict = {}
    out_log_keys = []
    out_lines = proc1.stdout.rstrip().split('\n')
    if (time_option!="off"):
      out_time = 0.
      for i in range(3):
        line = out_lines[-1]
        del out_lines[-1]
        time_match = time_exp.match(line)
        if time_match:
          ( time_name, time_m, time_s ) = time_match.groups()
          if time_name==time_option:
            out_time = float(time_m)*60+float(time_s)
    for line in out_lines:
        for fmatch in [fexp.match(line) for fexp in fexps]:
            if fmatch:
                grps = fmatch.groups()
                if len(grps)==2:
                    if grps[0] in out_log_dict:
                        logging.error(prefix + 'redefinition of {} in output'.format(grps[0]))
                    else:
                        out_log_dict[grps[0]] = grps[1]
                        out_md5_dict[grps[0]] = hashlib.md5(grps[1].encode('utf-8')).hexdigest()
                        # so to memorize results ordering
                        out_log_keys.append(grps[0])
                else:
                    for grp in grps:
                        out_log_matches.append(grp)
                        out_md5_matches.append(hashlib.md5(grp.encode('utf-8')).hexdigest())

    # collect matching groups in reference
    proc2 = subprocess.run("cat {} 2>&1".format(ref_file_name),
                           shell=True, executable='bash', stdout=subprocess.PIPE, stderr=subprocess.PIPE , universal_newlines=True)
    out_ref_matches = []
    out_ref_dict = {}
    out_ref_keys = []
    ref_lines = proc2.stdout.rstrip().split('\n')
    if (time_option!="off"):
      ref_time = 0.
      for i in range(3):
        line = ref_lines[-1]
        del ref_lines[-1]
        time_match = time_exp.match(line)
        if time_match:
          ( time_name, time_m, time_s ) = time_match.groups()
          if time_name==time_option:
            ref_time = float(time_m)*60+float(time_s)
    for line in ref_lines:
        for fmatch in [fexp.match(line) for fexp in fexps]:
            if fmatch:
                grps = fmatch.groups()
                if len(grps)==2:
                    if grps[0] in out_ref_dict:
                        logging.error(prefix + 'redefinition of {} in reference'.format(grps[0]))
                    else:
                        out_ref_dict[grps[0]] = grps[1]
                        # so to memorize results ordering
                        out_ref_keys.append(grps[0])
                else:
                    for grp in grps:
                        out_ref_matches.append(grp)

    # complete lacking matches in lists
    #while len(out_log_matches) < len(out_ref_matches):
    #    out_log_matches.append('EMPTY STRING')
    #    out_md5_matches.append('EMPTY STRING')
    #while len(out_log_matches) > len(out_ref_matches):
    #    out_ref_matches.append('EMPTY STRING')

    # prepare comparisons between output and ref
    nbdiff = 0

    # compare single matches
    zipped = zip(out_log_matches, out_md5_matches, out_ref_matches)
    if md5:
        for tpl in zipped:
            if tpl[1] != tpl[2]:
                logging.info(prefix+'md5("{}") != {}'.format(tpl[0], tpl[2]))
                nbdiff += 1
    else:
        #for tpl in zipped:
        #    if tpl[0] != tpl[2]:
        #        logging.info(prefix+"{} != {}".format(tpl[0], tpl[2]))
        #        nbdiff += 1
        for line in list(differ.compare(out_ref_matches, out_log_matches)):
            if ((line[0]=='+')or(line[0]=='-')):
                logging.info(prefix+"{}".format(line))
                nbdiff += 1

    # compare key/value matches (not implemented for md5)
    for k in out_log_keys:
        if k in out_ref_dict:
            if out_log_dict[k] != out_ref_dict[k]:
                logging.info(prefix + "for {}, {} != {}".format(k,out_log_dict[k],out_ref_dict[k]))
                nbdiff += 1
        else:
            logging.info(prefix + 'unexpected {}'.format(k))
            nbdiff += 1
    for k in out_ref_keys:
        if not k in out_log_dict:
            logging.info(prefix + 'lacking {}'.format(k))
            nbdiff += 1

    # optional time comparison
    if (time_option!="off"):
      if ((abs(out_time-ref_time)/ref_time)>.2):
        logging.info(prefix + "- {} {}s".format(time_option,ref_time))
        logging.info(prefix + "+ {} {}s".format(time_option,out_time))
        nbdiff += 1

    # final summary
    if nbdiff == 0:
        logging.info(prefix+'==')
        return 0 ;
    else:
        return 1


# ==========================================
# SUBCOMMAND: Crypt

def apply_crypt( target,multi,expanded ):
    fexps = [re.compile('^'+f.replace('%', '.*')+'$') for f in target['diff_filters_in']]
    ref_file_name = '{}.ref'.format(target['name'])
    md5_file_name = '{}.md5'.format(target['name'])
    with open(ref_file_name) as ref_content:
        logging.info('crypting {}.ref into {}.md5'.format(target['name'], target['name']))
        with open(md5_file_name,'w') as md5_content:
            for ref_line in ref_content:
                line = ref_line.rstrip()
                for fmatch in [fexp.match(line) for fexp in fexps]:
                    if fmatch:
                        for grp in fmatch.groups():
                            md5_content.write(hashlib.md5(grp.encode('utf-8')).hexdigest()+'\n')


# ==========================================
# main work in a given directory

CWD = os.getcwd()
differ = difflib.Differ() # https://docs.python.org/3/library/difflib.html

def process_directory(workdir, subcommand, args) :
    os.chdir(workdir)
    if (workdir!='.') and (workdir!=CWD) :
      logging.info('>>>>> '+workdir)  
    #return 0

    # search for ovalfile in the current working directory
    syspathbackup = sys.path
    sys.path = ( os.getcwd() , )
    import ovalfile as config
    sys.path = syspathbackup

    returncode = 0

    # prepare the list of all targets
    all_target_names = [t['name'] for t in config.targets]
    all_targets = {t['name'] : t for t in config.targets}
    if (subcommand == 'diff' or subcommand == 'run-diff' or subcommand == 'val' or subcommand == 'crypt'):
        for target_name in all_target_names:
            target = all_targets[target_name]
            if (subcommand == 'run-diff' or os.path.isfile(target_name+'.out')):
                target['out'] = target_name+'.out'
            else:
                target['out'] = None
            if os.path.isfile(target_name+'.ref'):
                target['ref'] = target_name+'.ref'
            else:
                target['ref'] = None
            if os.path.isfile(target_name+'.md5'):
                target['md5'] = target_name+'.md5'
            else:
                target['md5'] = None

    # select the active targets.
    # when there is a wildcard '%' and the command is 'd',
    # filter-out the targets which do not have a log and a ref.
    # multi says if there are several expanded targets
    # expanded says if there are targets expanded from wildcard
    target_names = []
    expanded = False
    for p in args.target:
        if '%' in p:
            exp = re.compile('^'+p.replace('%', '.*')+'$')
            for target_name in all_target_names:
                target = all_targets[target_name]
                if exp.match(target_name):
                    if ((subcommand == 'diff' and target['out'] and (target['ref'] or target['md5'])) or
                        (subcommand == 'crypt' and target['ref']) or
                        (subcommand == 'val' and target['out']) or
                        (subcommand != 'diff' and args.subcommand != 'val' and args.subcommand != 'crypt')):
                        logging.debug('expand {} to {}'.format(p, target_name))
                        target_names.append(target_name)
                        expanded = True
        else:
            if p in all_target_names:
                target_names.append(p)
            else:
                logging.warning('unknown target '+p)
    multi = len(target_names) > 1
    logging.debug('targets: {}'.format(target_names))

    # add the filters
    for target_name in target_names:
        target = all_targets[target_name]
        target['run_filters_out'] = []
        for f in config.run_filters_out:
            exp = re.compile('^'+f['apply'].replace('%', '.*')+'$')
            if exp.match(target_name):
                target['run_filters_out'].append(f['re'])
        target['diff_filters_in'] = []
        for f in config.diff_filters_in:
            exp = re.compile('^'+f['apply'].replace('%', '.*')+'$')
            if exp.match(target_name):
                target['diff_filters_in'].append(f['re'])
                
    # execute the subcommand
    if subcommand == 'list':
        for target_name in target_names:
            target = all_targets[target_name]
            logging.info("{}: {}".format(target_name, target["command"]))
    elif subcommand == 'build':
        for target_name in target_names:
            res = apply_build(all_targets[target_name],multi,expanded)
            returncode = returncode or res
    elif subcommand == 'run':
        for target_name in target_names:
            res = apply_run(all_targets[target_name],multi,expanded)
            returncode = returncode or res
    elif subcommand == 'diff':
        for target_name in target_names:
            res = apply_diff(all_targets[target_name],multi,expanded)
            returncode = returncode or res
    elif subcommand == 'run-diff':
        for target_name in target_names:
            res = apply_run(all_targets[target_name],multi,expanded)
            returncode = returncode or res
            res  =apply_diff(all_targets[target_name],multi,expanded)
            returncode = returncode or res
    elif subcommand == 'prod':
        for target_name in target_names:
            res = apply_build(all_targets[target_name],multi,expanded)
            returncode = returncode or res
            res = apply_run(all_targets[target_name],multi,expanded)
            returncode = returncode or res
            res = apply_diff(all_targets[target_name],multi,expanded)
            returncode = returncode or res
    elif subcommand == 'val':
        for target_name in target_names:
            command = 'cp -f {}.out {}.ref'.format(target_name, target_name)
            logging.info(command)
            subprocess.check_call(command, shell=True)
            target = all_targets[target_name]
            if target['md5']:
                apply_crypt(target,multi,expanded)
    elif subcommand == 'crypt':
        for target_name in target_names:
            apply_crypt(all_targets[target_name],multi,expanded)
    elif subcommand == 'filter-out':
        for target_name in target_names:
            logging.debug('process target {}'.format(target_name))
            if not os.path.isfile(target_name+'.out'):
                logging.warning('lacking file '+target_name+'.out')
                continue
            target = all_targets[target_name]
            fexps = [re.compile('^'+f.replace('%', '.*')+'$') for f in target['diff_filters_in']]
            proc1 = subprocess.Popen("cat {}.out 2>&1".format(target_name),
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True, executable='bash', universal_newlines=True)
            out_value, err_value = proc1.communicate()
            out_log_matches = []
            for line in out_value.split('\n'):
                for fmatch in [fexp.match(line) for fexp in fexps]:
                    if fmatch:
                        out_log_matches.extend(fmatch.groups())
            nbdiff = 0
            if multi or expanded:
                prefix = target_name+': '
            else:
                prefix = ''
            for group in out_log_matches:
                logging.info(prefix+"{}".format(group))
                nbdiff += 1
            if nbdiff == 0:
                logging.info(prefix+'no match')
    elif subcommand == 'filter-ref':
        for target_name in target_names:
            logging.debug('process target {}'.format(target_name))
            if not os.path.isfile(target_name+'.ref'):
                logging.warning('lacking file '+target_name+'.ref')
                continue
            target = all_targets[target_name]
            fexps = [re.compile('^'+f.replace('%', '.*')+'$') for f in target['diff_filters_in']]
            proc1 = subprocess.Popen("cat {}.ref 2>&1".format(target_name),
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True, executable='bash', universal_newlines=True)
            out_value, err_value = proc1.communicate()
            out_ref_matches = []
            for line in out_value.split('\n'):
                for fmatch in [fexp.match(line) for fexp in fexps]:
                    if fmatch:
                        out_ref_matches.extend(fmatch.groups())
            nbdiff = 0
            if multi or expanded:
                prefix = target_name+': '
            else:
                prefix = ''
            for group in out_ref_matches:
                logging.info(prefix+"{}".format(group))
                nbdiff += 1
            if nbdiff == 0:
                logging.info(prefix+'no match')
    else:
        logging.error('UNKNOWN SUBCOMMAND: '+subcommand)

    del sys.modules['ovalfile']
    return returncode


# ==========================================
# find workdirs

def try_workdir( element, workdirs ):
  if element[0] == '.' :
    return
  if not os.path.isdir(element) :
    return
  ovalcfg = os.path.join(element,'ovalfile.py')
  if os.path.isfile(ovalcfg) :
    workdirs.append(element)
  else :
    for subelement in os.listdir(element) :
      subelementpath = os.path.join(element,subelement)
      try_workdir(subelementpath,workdirs)


# ==========================================
# process command-line options

parser = argparse.ArgumentParser(description='Automatic running and diffing of executables')
#parser.add_argument('-c', action="store_true", default=False, \
#                    help='crypt the reference output')
parser.add_argument('subcommand',
                    help='the oval subcommand to apply')
parser.add_argument('target', nargs='*', default=['%'],
                    help='the list of targets to be processed')
args = parser.parse_args()

# find ovalfiles and establish workdirs
workdirs = []
try_workdir(os.getcwd(),workdirs)

# ==========================================
# Prepare subcommand

abbrevs = {
    'help': 'help', 'hel': 'help', 'he': 'help', 'h': 'help',
    'list': 'list', 'lis': 'list', 'li': 'list', 'l': 'list',
    'build': 'build', 'buil': 'build', 'bui': 'build', 'bu': 'build', 'b': 'build',
    'run': 'run', 'ru': 'run', 'r': 'run',
    'val': 'val', 'va': 'val', 'v': 'val',
    'diff': 'diff', 'dif': 'diff', 'di': 'diff', 'd': 'diff',
    'crypt': 'crypt', 'cryp': 'crypt', 'cry': 'crypt', 'cr': 'crypt', 'c': 'crypt',
    'filter-out': 'filter-out', 'fo': 'filter-out',
    'filter-ref': 'filter-ref', 'fr': 'filter-ref',
    'run-diff': 'run-diff', 'rd': 'run-diff',
    'prod': 'prod', 'pro': 'prod', 'pr': 'prod', 'p': 'prod',
}
abbrev = args.subcommand
if abbrev in abbrevs.keys():
    subcommand = abbrevs[abbrev]
else:
    subcommand = abbrev

# ==========================================
# Additional Help

def additional_help():
    print('''
subcommands:
  help: display the list of targets, as described in in ovalfile.py.
  list: display the list of targets, as described in in ovalfile.py.
  run: execute the shell command associated with the given target name.
  validate: copy the last execution output into the target reference.
  diff: compare the last execution output with the target reference.

abbreviated subcommands:
  Each subcommand can be abbreviated woth a subset of its first letters,
  such as 'ru' or 'r' for 'run', 'lis', 'li' or 'l' for 'list' etc.

configuration files:
  Files called 'ovalfile.py' are recursively searched for in the current
  directory and all its subdirectories.

list of available targets:
  Each file 'ovalfile.py' is expected to define the targets of its
  corresponding directory, within a python list called 'targets´,
  each target being a dictionary with a 'name' and an associated
  shell 'command'. A way to get the list of local targets of a
  directory is to move there and type 'oval list'.

wildcards in target names:
  When running an oval subcommand, one can use wildcards:
  'oval r <pattern1> <pattern2>...'
  The only wildcard character is '%'.
  One can check how a given pattern expands : 'oval l <pattern>'.

ovalfile.py filters:
  run_filters_out: regular expression for the lines to be erased from the output.
  diff_filters_in: regular expression for the lines to be compared.
    If the regular expression has two groups, it is considered as a pair name-value.
    A dictionary will be built, the comparison will be between the current output
    and the ref dictionaries.
''')

# ==========================================
# Start to process directories, in parallel if subcommand is "run"

globalreturncode = 0
if subcommand=='help':
  parser.print_help()
  additional_help()
elif subcommand=='run':
  pools = concurrent.futures.ProcessPoolExecutor(max_workers=10)
  results = {}
  for workdir in workdirs :
    results[workdir] = pools.submit(process_directory,workdir,subcommand,args)
  for workdir in workdirs :
    tmpreturncode = results[workdir].result()
    globalreturncode = globalreturncode or tmpreturncode
else:
  for workdir in workdirs :
    tmpreturncode = process_directory(workdir,subcommand,args)
    globalreturncode = globalreturncode or tmpreturncode
sys.exit(globalreturncode)
