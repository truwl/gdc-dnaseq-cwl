#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --workdir=${xx_scratch_dir_xx}
#SBATCH --cpus-per-task=${xx_slurm_resource_cores_xx}
#SBATCH --mem=${xx_slurm_resource_mem_megabytes_xx}
#SBATCH --gres=SCRATCH:${xx_slurm_resource_disk_gigabytes_xx}

CWL_WORKFLOW_GIT_REPO=${xx_cwl_workflow_git_repo_xx}
CWL_WORKFLOW_GIT_HASH=${xx_cwl_workflow_git_hash_xx}
CWL_WORKFLOW_REL_PATH=${xx_cwl_workflow_rel_path_xx}
CWL_TASK_GIT_REPO=${xx_cwl_task_git_repo_xx}
CWL_TASK_GIT_BRANCH=${xx_cwl_task_git_branch_xx}
CWL_TASK_REL_PATH=${xx_cwl_task_rel_path_xx}
SCRATCH_DIR=${xx_scratch_dir_xx}
TASK_UUID=${xx_task_uuid_xx}
VIRTUALENV_NAME=${xx_virtualenv_name_xx}
TASK_DIR=repo/task
WORKFLOW_DIR=repo/workflow

function activate_virtualenv()
{
    local virtualenv_name=${1}

    source /usr/local/bin/virtualenvwrapper.sh
    source ${HOME}/.virtualenvs/${virtualenv_name}/bin/activate
}

function git_clone()
{
    local clone_dir=${1}
    local git_branch=${2}
    local git_repo=${3}

    local repo=$(basename ${git_repo})
    local repo_dir=${clone_dir}/${repo}
    local prev_dir=$(pwd)

    export http_proxy=http://cloud-proxy:3128
    export https_proxy=http://cloud-proxy:3128
    cd ${clone_dir}
    git clone ${git_repo}
    cd ${repo_dir}
    git checkout ${git_branch}
    cd ${prev_dir}
    unset http_proxy
    unset https_proxy
}

function runner()
{
    local task_path=${1}
    local workflow_path=${2}
    local work_dir=${3}

    local prev_dir=$(pwd)
    cd ${work_dir}
    local cache_dir=cache
    local tmp_dir=tmp
    mkdir ${cache_dir}
    mkdir ${tmp_dir}
 
    cwltool  --debug --rm-tmpdir --rm-container --tmp-outdir-prefix ${cache_dir} --tmpdir-prefix ${tmp_dir} --custom-net bridge --outdir ${work_dir} ${workflow_path} ${task_path}
    cd ${prev_dir}
}

function main()
{
    local cwl_workflow_git_repo=${CWL_WORKFLOW_GIT_REPO}
    local cwl_workflow_git_hash=${CWL_WORKFLOW_GIT_HASH}
    local cwl_workflow_rel_path=${CWL_WORKFLOW_REL_PATH}
    local cwl_task_git_repo=${CWL_TASK_GIT_REPO}
    local cwl_task_git_branch=${CWL_TASK_GIT_BRANCH}
    local cwl_task_rel_path=${CWL_TASK_REL_PATH}
    local task_uuid=${TASK_UUID}
    local scratch_dir=${SCRATCH_DIR}
    local virtualenv_name=${VIRTUALENV_NAME}

    local work_dir=${scratch_dir}/${task_uuid}
    local workflow_dir=${work_dir}/${WORKFLOW_DIR}
    local workflow_path=${workflow_dir}/${cwl_workflow_rel_path}
    local task_dir=${work_dir}/${TASK_DIR}
    local task_path=${task_dir}/${cwl_task_rel_path}

    echo mkdir -p ${workflow_dir}
    mkdir -p ${workflow_dir}
    echo mkdir -p ${task_dir}
    mkdir -p ${task_dir}

    git_clone ${workflow_dir} ${cwl_workflow_git_hash} ${cwl_workflow_git_repo}
    git_clone ${task_dir} ${cwl_task_git_branch} ${cwl_task_git_repo}
    activate_virtualenv ${virtualenv_name}
    runner ${task_path} ${workflow_path} ${work_dir}
    if [ $? -ne 0 ]
    then
        echo FAIL_RUNNER
        #rm -rf ${work_dir}
        exit 1
    fi
    #rm -rf ${work_dir}
}

main "$@"
