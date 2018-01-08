video_base_path = '/media/sunx/Data/ImageNet/train';
output_path = '/home/sunx/output/ours';
annotation_base_path = '/media/sunx/Data/ImageNet/Annotations';
[recall, smT_IoU] = run(video_base_path,'ILSVRC2015_train_00166001',annotation_base_path, output_path, false);