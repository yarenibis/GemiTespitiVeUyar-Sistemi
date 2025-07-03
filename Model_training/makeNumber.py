import os
from natsort import natsorted

dataset_path = r"C:\Users\yaren\PycharmProjects\GemiTespiti\Ships"

for folder in os.listdir(dataset_path):
    folder_path = os.path.join(dataset_path, folder)

    if os.path.isdir(folder_path):
        images = [f for f in os.listdir(folder_path) if f.lower().endswith(('.jpg', '.jpeg', '.png'))] #.jpg, .jpeg, .png uzantılı dosyalar filtrelenir.
        images = natsorted(images) #natsorted ile sırayla adlandırır.

        #Aynı anda 1.jpg gibi adlara yeniden adlandırma çakışma yaratabileceği için önce geçici adla (_temp_1.jpg) yeniden adlandırılır.
        temp_names = {}
        for index, image_file in enumerate(images, start=1):
            old_path = os.path.join(folder_path, image_file)

            # Eğer dosya yoksa devam et
            if not os.path.exists(old_path):
                print(f" Dosya bulunamadı: {old_path}, atlanıyor...")
                continue

            temp_path = os.path.join(folder_path, f"_temp_{index}.jpg")
            os.rename(old_path, temp_path)
            temp_names[temp_path] = os.path.join(folder_path, f"{index}.jpg")
            
        #her geçici dosya kalıcı haline çevrilir.
        for temp_path, new_path in temp_names.items():
            try:
                os.rename(temp_path, new_path)
                print(f"{temp_path} -> {new_path}")
            except Exception as e:
                print(f"Hata: {e}")

print(" Tüm klasörlerdeki resimler başarıyla numaralandırıldı!")



