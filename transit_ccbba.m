clc, close all, clear all
addpath('functions');

rng(1);

global DEBUG_LEVEL
DEBUG_LEVEL = 1;

DEP_AND = 1;
DEP_OR = 2;
DEP_EXC = -1;

TEMP_AFTER = 1;
TEMP_BEFORE = 0;

NUM_AGENTS = 5;                             % Number of agents
NUM_DELIVERIES = 12;                             % Number of tasks
NUM_ACTIVITIES = 2;
NUM_BASES = 5;

MAX_TASKS_PER_AGENT = 10;

% ADJ_MAT = diag(ones(NUM_AGENTS-1, 1), -1) + diag(ones(NUM_AGENTS-1, 1), 1);
ADJ_MAT = ones(NUM_AGENTS) - eye(NUM_AGENTS);


%% Initialization

