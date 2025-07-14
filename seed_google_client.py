import os
from supabase import create_client
from dotenv import load_dotenv



def seed_google_client():
    load_dotenv()
    print(os.getenv('SUPABASE_URL'), 'SUPABASE_URL')
    """
    This is supposed to create a google clients column for the use so that the user can be able
    to connect their google account to the appplication.
    """
    supabase = create_client(
        os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    )

    try:
        response = supabase.table("google_clients").upsert(
            {
                "id": 10,
                "client_id": os.getenv("GOOGLE_CLIENT_ID"),
                "client_secret": os.getenv("GOOGLE_CLIENT_SECRET"),
                "type": "oauth",
            }, on_conflict="client_id"
        ).execute()
        print(response, 'this is the response' )
        print("Data seeded successfully")
    except Exception as e:
        print(f"seeding failed: {e}")

if __name__ == "__main__":
    seed_google_client()