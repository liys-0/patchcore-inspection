#!/bin/bash
#SBATCH --job-name=patchcore_test
#SBATCH --output=patchcore_test_%j.log
#SBATCH --error=patchcore_test_%j.err
#SBATCH --partition=gpu
#SBATCH --gpus=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00

# ==========================================
# Environment Setup
# ==========================================
# Uncomment and modify to load your specific environment
# source .venv/bin/activate
# module load cuda/11.x

echo "Starting PatchCore test job on $HOSTNAME"
echo "Job ID: $SLURM_JOB_ID"

# ==========================================
# Paths & Variables
# ==========================================
# IMPORTANT: Update datapath and loadpath to your actual directories!
datapath=/path_to_mvtec_folder/mvtec
loadpath=/path_to_pretrained_patchcores_models
modelfolder=IM224_WR50_L2-3_P01_D1024-1024_PS-3_AN-1_S0
savefolder=evaluated_results'/'$modelfolder

# Define the dataset categories you want to evaluate on
datasets=('bottle' 'cable' 'capsule' 'carpet' 'grid' 'hazelnut' 'leather' 'metal_nut' 'pill' 'screw' 'tile' 'toothbrush' 'transistor' 'wood' 'zipper')
dataset_flags=($(for dataset in "${datasets[@]}"; do echo '-d '$dataset; done))
model_flags=($(for dataset in "${datasets[@]}"; do echo '-p '$loadpath'/'$modelfolder'/models/mvtec_'$dataset; done))

# ==========================================
# Run Evaluation
# ==========================================
env PYTHONPATH=src python bin/load_and_evaluate_patchcore.py \
    --gpu 0 \
    --seed 0 \
    $savefolder \
    patch_core_loader "${model_flags[@]}" --faiss_on_gpu \
    dataset --resize 366 --imagesize 320 "${dataset_flags[@]}" mvtec $datapath

echo "Evaluation complete."
