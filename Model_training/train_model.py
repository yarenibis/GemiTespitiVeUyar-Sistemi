import os
import random
import shutil
import numpy as np
import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import ModelCheckpoint

# Klasörleri Hazırlama ve %64/16/20 Bölme
original_dataset_dir = 'C:\\Users\\yaren\\PycharmProjects\\GemiTespiti\\Ships'
base_dir = 'C:\\Users\\yaren\\PycharmProjects\\GemiTespiti\\Split_Ships'

train_dir = os.path.join(base_dir, 'train')
val_dir = os.path.join(base_dir, 'val')
test_dir = os.path.join(base_dir, 'test')

#kodu her çalıştırdığında önceki veri bölmelerini sıfırlar ve yeniden temiz başlar.-Split_Ships klasörü varsa, onu tamamen sil.
if os.path.exists(base_dir):
    shutil.rmtree(base_dir)
#tekrar test,val,train oluştur.
os.makedirs(train_dir), os.makedirs(val_dir), os.makedirs(test_dir)

classes = os.listdir(original_dataset_dir) #ships içindeki klasörleri listeler.

for cls in classes:
    cls_path = os.path.join(original_dataset_dir, cls)
    images = [f for f in os.listdir(cls_path) if os.path.isfile(os.path.join(cls_path, f))] # Sadece resimleri (dosyaları) alır, alt klasörleri atlar.

    if len(images) == 0:
        continue

    random.shuffle(images) #resimleri rastgele karıştırır
    total = len(images)

    train_split = int(total * 0.64)
    val_split = int(total * 0.16)

#yukarda hesaplanan oranlara göre üçe böler.
    train_imgs = images[:train_split]
    val_imgs = images[train_split:train_split + val_split]
    test_imgs = images[train_split + val_split:]

# İçinde cls alt klasörünü oluşturur (örneğin: Split_Ships/train/warship).
    for folder, img_list in zip([train_dir, val_dir, test_dir], [train_imgs, val_imgs, test_imgs]):
        class_folder = os.path.join(folder, cls)
        os.makedirs(class_folder, exist_ok=True)
        # Resmin kaynağını (src) alır (Ships/warship/abc.jpg)
        # Hedefe (dst) kopyalar (Split_Ships/train/warship/abc.jpg)
        for img in img_list:
            src = os.path.join(cls_path, img)
            dst = os.path.join(class_folder, img)
            shutil.copy(src, dst)

print(" Veriler %64 eğitim, %16 validation, %20 test olarak ayrıldı!")


train_datagen = ImageDataGenerator(
    rescale=1. / 255,
    rotation_range=45,
    width_shift_range=0.3, #sağa sola rastgele 30 derece kaydırıyor.
    height_shift_range=0.3, #yukarı aşağı rastgele 30 derece kaydırıyor.
    shear_range=0.3,
    zoom_range=0.3,
    horizontal_flip=True, #restgele yatay çevirme
    fill_mode='nearest'
)

test_datagen = ImageDataGenerator(rescale=1. / 255)

train_data = train_datagen.flow_from_directory(
    train_dir,
    target_size=(128, 128),
    batch_size=32,
    class_mode='categorical',
    shuffle=True #veriler karıştırılıp modelin ezberlemesi önlenir.
)

val_data = test_datagen.flow_from_directory(
    val_dir,
    target_size=(128, 128),
    batch_size=32,
    class_mode='categorical',
    shuffle=False
)

test_data = test_datagen.flow_from_directory(
    test_dir,
    target_size=(128, 128),
    batch_size=32,
    class_mode='categorical',
    shuffle=False
)


model = models.Sequential([
    layers.Conv2D(32, (3, 3), activation='relu', input_shape=(128, 128, 3)),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(64, (3, 3), activation='relu'),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(128, (3, 3), activation='relu'),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(128, (3, 3), activation='relu'),
    layers.MaxPooling2D((2, 2)),
    layers.Flatten(),
    layers.Dense(256, activation='relu'),
    layers.Dense(train_data.num_classes, activation='softmax')
])

model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

checkpoint_cb = ModelCheckpoint(
    'gemi_model_max_acc_deneme.h5',
    monitor='val_accuracy',
    save_best_only=True,
    mode='max',
    verbose=1
)


history = model.fit(
    train_data,
    epochs=50,
    validation_data=val_data,
    callbacks=[checkpoint_cb]
)



