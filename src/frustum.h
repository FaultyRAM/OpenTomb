
#ifndef FRUSTUM_H
#define FRUSTUM_H

#include <cstdint>
#include <memory>
#include <vector>
#include "bullet/LinearMath/btScalar.h"
#include "vmath.h"

struct Room;
struct Portal;
class Render;
struct OBB;
struct Polygon;
struct Camera;

struct Frustum
{
    std::vector<btVector3> planes;                                              // clip planes
    std::vector<btVector3> vertices;                                            // frustum vertices
    btVector3* cam_pos = nullptr;                                               ///@TODO: delete it!
    btVector3  norm = {0,0,0};                                                  // main frustum clip plane (inv. plane of parent portal)

    uint16_t parents_count = 0;
    std::weak_ptr<Frustum> parent;                                              // by who frustum was generated; parent == NULL is equal generated by camera

    bool hasParent(const std::shared_ptr<Frustum> &parent);
    bool isPolyVisible(struct Polygon *p);
    bool isAABBVisible(const btVector3 &bbmin, const btVector3 &bbmax);
    bool isOBBVisible(OBB *obb);
    static bool isOBBVisibleInRoom(OBB *obb, const Room &room);

    static std::shared_ptr<Frustum> portalFrustumIntersect(Portal* portal, std::shared_ptr<Frustum> emitter, Render *render);         // Основная функция для работы с порталами.
    void splitPrepare(struct Portal *p);// подготовка фрустума к сплиту
    void genClipPlanes(Camera* cam);                      // генерация плоскостей отсечения
    int split_by_plane(const btVector3 &splitPlane);              // отсечение части портала плоскостью
};

/**
 * Draws wireframe of this frustum.
 *
 * Expected state:
 *  - Vertex array is enabled, color, tex coord, normal disabled
 *  - No vertex buffer object is bound
 *  - Texturing is disabled
 *  - Alpha test is disabled
 *  - Blending is enabled
 *  - Lighting is disabled
 *  - Line width is set to desired width (typically 3.0)
 *  - Current color set to desired color (typically red)
 * Ignored state:
 *  - Currently bound texture.
 *  - Currently bound element buffer.
 *  - Vertex pointer (changes it)
 * Changed state:
 *  - Current position will be arbitrary.
 *  - Vertex pointer will be arbitray.
 */

#endif
