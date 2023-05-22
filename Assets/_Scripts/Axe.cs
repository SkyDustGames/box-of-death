using UnityEngine;

public class Axe : MonoBehaviour {

    private float speed;
    private Vector3 lastPos;
    private bool dragging;

    private void Update() {
        speed = Vector3.Distance(transform.position, lastPos);
        lastPos = transform.position;
    }

    private void OnMouseDown() {
        dragging = true;
    }

    private void OnMouseUp() {
        dragging = false;
    }

    private void OnCollisionEnter2D(Collision2D collision) {
        if (collision.gameObject.CompareTag("Player"))
            collision.gameObject.GetComponent<PlayerHealth>().Damage(speed*5, PlayerHealth.DeathType.Axe);

        if (dragging && speed >= 0.1f)
            Destroy(gameObject);
    }
}