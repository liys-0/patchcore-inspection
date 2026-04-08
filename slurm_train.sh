#!/bin/bash
#SBATCH --job-name=patchcore_train
#SBATCH --output=patchcore_train_%j.log
#SBATCH --error=patchcore_train_%j.err
#SBATCH --partition=gpu
#SBATCH --gpus=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=48:00:00

# ==========================================
# Environment Setup
# ==========================================
# Uncomment and modify to load your specific environment
# source .venv/bin/activate
# module load cuda/11.x

echo "Starting PatchCore training job on $HOSTNAME"
echo "Job ID: $SLURM_JOB_ID"

# ==========================================
# Paths & Variables
# ==========================================
# IMPORTANT: Update datapath to your actual MVTec AD dataset directory!
datapath=/path_to_mvtec_folder/mvtec

# Define the dataset categories you want to train on
datasets=('bottle' 'cable' 'capsule' 'carpet' 'grid' 'hazelnut' 'leather' 'metal_nut' 'pill' 'screw' 'tile' 'toothbrush' 'transistor' 'wood' 'zipper')
dataset_flags=($(for dataset in "${datasets[@]}"; do echo '-d '$dataset; done))

# ==========================================
# Run Training
# ==========================================
# Note: --gpu 0 assumes CUDA_VISIBLE_DEVICES makes the assigned GPU available as ID 0
env PYTHONPATH=src python bin/run_patchcore.py \
    --gpu 0 \
    --seed 0 \
    --save_patchcore_model \
    --log_group IM224_WR50_L2-3_P01_D1024-1024_PS-3_AN-1_S0 \
    --log_online \
    --log_project MVTecAD_Results results \
    patch_core -b wideresnet50 -le layer2 -le layer3 --faiss_on_gpu \
    --pretrain_embed_dimension 1024 --target_embed_dimension 1024 --anomaly_scorer_num_nn 1 --patchsize 3 \
    sampler -p 0.1 approx_greedy_coreset \
    dataset --resize 256 --imagesize 224 "${dataset_flags[@]}" mvtec $datapath

echo "Training complete."
