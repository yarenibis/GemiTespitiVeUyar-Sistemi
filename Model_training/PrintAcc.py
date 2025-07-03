import tensorflow as tf
import os
from tensorflow.keras.preprocessing.image import ImageDataGenerator


BASE_DIR = 'C:\\Users\\yaren\\PycharmProjects\\GemiTespiti\\Split_Ships'
train_dir = os.path.join(BASE_DIR, 'train')
val_dir = os.path.join(BASE_DIR, 'val')
test_dir = os.path.join(BASE_DIR, 'test')


IMAGE_SIZE = (128, 128)
BATCH_SIZE = 32
CLASS_MODE = 'categorical'


datagen = ImageDataGenerator(rescale=1./255)

train_data = datagen.flow_from_directory(
    train_dir,
    target_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    class_mode=CLASS_MODE,
    shuffle=False
)

val_data = datagen.flow_from_directory(
    val_dir,
    target_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    class_mode=CLASS_MODE,
    shuffle=False
)

test_data = datagen.flow_from_directory(
    test_dir,
    target_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    class_mode=CLASS_MODE,
    shuffle=False
)


model_path = "C:\\Users\\yaren\\PycharmProjects\\GemiTespiti\\gemi_model_max_acc_deneme.h5"

#model evaluate: eğitilmiş modeli test verisi üzerinde değerlendirir.

try:
    print(f"\n Model Yükleniyor: {model_path}")
    model = tf.keras.models.load_model(model_path)

    print("\n Train verisi değerlendiriliyor...")
    train_loss, train_acc = model.evaluate(train_data, verbose=1)
    print(f"  Train Loss: {train_loss:.4f} | Train Accuracy: {train_acc:.4f} ({train_acc * 100:.2f}%)")

    print("\n Validation verisi değerlendiriliyor...")
    val_loss, val_acc = model.evaluate(val_data, verbose=1)
    print(f"  Val Loss:   {val_loss:.4f} | Val Accuracy:   {val_acc:.4f} ({val_acc * 100:.2f}%)")

    print("\n Test verisi değerlendiriliyor...")
    test_loss, test_acc = model.evaluate(test_data, verbose=1)
    print(f"  Test Loss:  {test_loss:.4f} | Test Accuracy:  {test_acc:.4f} ({test_acc * 100:.2f}%)")

except Exception as e:
    print(f" Değerlendirme hatası: {e}")
