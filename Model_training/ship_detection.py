import cv2
import tensorflow as tf
import numpy as np

# Modeli yükleme
model = tf.keras.models.load_model('gemi_model.h5')

# Klasörlerden sınıf etiketlerini almak
class_names = ['cruise_ship', 'ferry_boat', 'freight_boat', 'sailboat', 'warship']  # Kendi sınıf isimlerinizi buraya ekleyin

# Video dosyasını açma
video_path = 'C:\\Users\\yaren\\PycharmProjects\\GemiTespiti\\videos_and_pics\\cargo_Ship.mp4'  # Video dosyasının yolu
cap = cv2.VideoCapture(video_path)

while True: #videodaki kareleri döngüyle okur.
    ret, frame = cap.read() #her kareyi okuyacak şekilde açıyor.
    if not ret:
        break

    # Videodaki her bir kareyi işlemek
    img_resized = cv2.resize(frame, (128, 128)) # Kareyi 128x128 boyutuna getirir
    img_array = np.array(img_resized) / 255.0  # Normalizasyon
    img_array = np.expand_dims(img_array, axis=0)  # Modelin beklediği şekle getirme: (1, 128, 128, 3)


    predictions = model.predict(img_array) #Model tahmin yapar.
    predicted_class_idx = np.argmax(predictions) #En yüksek değerin indeksini bulur
    print(f"Predicted class index: {predicted_class_idx}")

    predicted_class_idx = np.argmax(predictions)
    predicted_class = class_names[predicted_class_idx] # indexin sınıfı belirlenir.



    # Sonucu ekranda gösterme
    label = f"Detected: {predicted_class}"
    cv2.putText(frame, label, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

    # Ekranda görüntüyü gösterme
    cv2.imshow('Ship Detection', frame)

    # 'q' tuşuna basarak çıkma
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Kaynakları serbest bırakma
cap.release()
cv2.destroyAllWindows()

