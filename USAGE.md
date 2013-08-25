Proje Kullanımı Hakkında Bilgilendirme
========
Yazan : @katanatr

İlk olarak yapacağımız işlem, çalışmaya başladığınız proje ile bağlantı kurmak. Unutmayın, bu sadece tek seferlik yapılacak bir işlem. 

`git remote add upstream https://github.com/xAKUMAx/koserver.git`
`git fetch upstream`

Yeni güncelleştirmeler için bunu kullanın. Automatic merge branch.

`git pull upstream master`

#### Proje üstünde yaptığınız değişiklikleri uzak sunucuya göndermek
#### (Pull Request)

> Yeni güncelleştirmeleri aldım, fakat ben de destek olmak istiyorum!

Proje üstünde çalıştınız ve bu çalışmaları göndermek istiyorsunuz. Bunun için yapacağımız işlem.

`git cherry-pick SHA-1`
`git push origin master`

#### Yapılan değişiklikleri geri almak

Proje üstünde değişiklik yaptığınızı varsayalım, yeni güncelleştirmeleri alırken çakışmalar olabiliyor bunlara dikkat etmeniz gerekiyor. Bunun için birkaç alternatif yol var. `git reset --hard` onlardan biri. Unutmamanız gereken **uncommit**  yani henüz push edilmemiş değişikleri geri alma işlemi.

Bir diğeri ise git üzerindeki işlemleri deponuza senkronize ettiniz ve bunun bir hata olduğunu fark ettiniz (benim gibi :relaxed:).

Senkronize ettiğiniz işlemi kaldırmak için yapacağımız işlem

`git reset SHA-1`  Kaldırmak istediğiniz SHA1 bilgisini değil, geri dönmek istediğiniz SHA1 bilgisini yazmayı unutmayın!

`git push origin HEAD --force` yaptığımız işlemi uzak sunucuya postalıyoruz.

###### SHA bilgisi nedir şeklinde sorular geldi.

![sha-1](https://f.cloud.github.com/assets/5224883/981000/e06022f8-073a-11e3-9792-2b5cdd645cc9.png)

SHA1 commit kimliğidir.
